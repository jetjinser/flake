{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.servicy.postgresqlBackup;
  defaultUser = "postgres";

  postgresqlBackupService =
    db: dumpCmd:
    let
      compressSuffixes = {
        "none" = "";
        "gzip" = ".gz";
        "zstd" = ".zstd";
      };
      compressSuffix = getAttr cfg.compression compressSuffixes;

      compressCmd = getAttr cfg.compression {
        "none" = "cat";
        "gzip" = "${pkgs.gzip}/bin/gzip -c -${toString cfg.compressionLevel} --rsyncable";
        "zstd" = "${pkgs.zstd}/bin/zstd -c -${toString cfg.compressionLevel} --rsyncable";
      };

      mkSqlPath = prefix: suffix: "${cfg.location}/${db}${prefix}.sql${suffix}";
      curFile = mkSqlPath "" compressSuffix;
      prevFile = mkSqlPath ".prev" compressSuffix;
      prevFiles = map (mkSqlPath ".prev") (attrValues compressSuffixes);
      inProgressFile = mkSqlPath ".in-progress" compressSuffix;
    in
    {
      enable = true;

      description = "Backup of ${db} database(s)";

      requires = [ "postgresql.service" ];

      path = [
        pkgs.coreutils
        config.services.postgresql.package
      ];

      script = ''
        set -e -o pipefail

        umask 0037 # ensure backup is only readable by user (& group)

        if [ -e ${curFile} ]; then
          rm -f ${toString prevFiles}
          mv ${curFile} ${prevFile}
        fi

        ${dumpCmd} \
          | ${compressCmd} \
          > ${inProgressFile}

        mv ${inProgressFile} ${curFile}
      '';

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
      };

      inherit (cfg) startAt;
    };

in
{

  imports = [
    (mkRemovedOptionModule [ "servicy" "postgresqlBackup" "period" ] ''
      A systemd timer is now used instead of cron.
      The starting time can be configured via <literal>servicy.postgresqlBackup.startAt</literal>.
    '')
  ];

  options = {
    servicy.postgresqlBackup = {
      enable = mkEnableOption (lib.mdDoc "PostgreSQL dumps");

      user = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        description = lib.mdDoc ''
          User under which the service should run. If this is the default value,
          the user will be created, with the specified group as the primary
          group.
        '';
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = defaultUser;
        description = lib.mdDoc ''
          Group under which the service should run. If this is the default value,
          the group will be created.
        '';
      };

      startAt = mkOption {
        default = "*-*-* 01:15:00";
        type = with types; either (listOf str) str;
        description = lib.mdDoc ''
          This option defines (see `systemd.time` for format) when the
          databases should be dumped.
          The default is to update at 01:15 (at night) every day.
        '';
      };

      backupAll = mkOption {
        default = cfg.databases == [ ];
        defaultText = literalExpression "servicy.postgresqlBackup.databases == []";
        type = lib.types.bool;
        description = lib.mdDoc ''
          Backup all databases using pg_dumpall.
          This option is mutual exclusive to
          `servicy.postgresqlBackup.databases`.
          The resulting backup dump will have the name all.sql.gz.
          This option is the default if no databases are specified.
        '';
      };

      databases = mkOption {
        default = [ ];
        type = types.listOf types.str;
        description = lib.mdDoc ''
          List of database names to dump.
        '';
      };

      location = mkOption {
        default = "/var/backup/postgresql";
        type = types.path;
        description = lib.mdDoc ''
          Path of directory where the PostgreSQL database dumps will be placed.
        '';
      };

      pgdumpOptions = mkOption {
        type = types.separatedString " ";
        default = "-C";
        description = lib.mdDoc ''
          Command line options for pg_dump. This options is not used
          if `config.servicy.postgresqlBackup.backupAll` is enabled.
          Note that config.servicy.postgresqlBackup.backupAll is also active,
          when no databases where specified.
        '';
      };

      compression = mkOption {
        type = types.enum [
          "none"
          "gzip"
          "zstd"
        ];
        default = "gzip";
        description = lib.mdDoc ''
          The type of compression to use on the generated database dump.
        '';
      };

      compressionLevel = mkOption {
        type = types.ints.between 1 19;
        default = 6;
        description = lib.mdDoc ''
          The compression level used when compression is enabled.
          gzip accepts levels 1 to 9. zstd accepts levels 1 to 19.
        '';
      };
    };

  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = cfg.backupAll -> cfg.databases == [ ];
          message = "config.servicy.postgresqlBackup.backupAll cannot be used together with config.servicy.postgresqlBackup.databases";
        }
        {
          assertion =
            cfg.compression == "none"
            || (cfg.compression == "gzip" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 9)
            || (cfg.compression == "zstd" && cfg.compressionLevel >= 1 && cfg.compressionLevel <= 19);
          message = "config.servicy.postgresqlBackup.compressionLevel must be set between 1 and 9 for gzip and 1 and 19 for zstd";
        }
      ];
    }
    (mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d '${cfg.location}' 0700 postgres - - -"
      ];
    })
    (mkIf (cfg.enable && cfg.backupAll) {
      systemd.services.postgresqlBackup = postgresqlBackupService "all" "pg_dumpall";
    })
    (mkIf (cfg.enable && !cfg.backupAll) {
      systemd.services = listToAttrs (
        map (
          db:
          let
            cmd = "pg_dump ${cfg.pgdumpOptions} ${db}";
          in
          {
            name = "postgresqlBackup-${db}";
            value = postgresqlBackupService db cmd;
          }
        ) cfg.databases
      );
    })
  ];

  meta.maintainers = with lib.maintainers; [ Scrumplex ];
}
