{
  config,
  pkgs,
  lib,
  ...

}:

let
  defaultUser = "openlist";
  cfg = config.services.openlist;
  format = pkgs.formats.json { };

  mkEmptyFreeformOption =
    description:
    lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
      };
      default = { };
      inherit description;
    };
in

{
  options.services.openlist = {
    enable = lib.mkEnableOption (lib.mdDoc "Whether to enable openlist.");

    package = lib.mkPackageOption pkgs "openlist" { };

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

    openFirewall = lib.mkEnableOption "Open ports in the firewall for openlist.";

    adminPasswordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "openlist admin authentication password file path.";
    };

    JWTSecretFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "openlist JWT secret file path.";
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;

        options = {
          force = lib.mkEnableOption ''
            By default OpenList reads the configuration from environment variables, set this field to true to force OpenList to read config from the configuration file
          '';
          site_url = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = lib.mdDoc "The address of your OpenList server, such as `https://pan.nn.ci`.";
          };

          database = mkEmptyFreeformOption ''
            The database configuration, which is by default sqlite3. Available options are sqlite3, mysql and postgres.
          '';
          scheme = lib.mkOption {
            type = lib.types.submodule {
              options = {
                address = lib.mkOption {
                  type = lib.types.str;
                  default = "0.0.0.0";
                };
                http_port = lib.mkOption {
                  type = lib.types.port;
                  default = 5244;
                };
                https_port = lib.mkOption {
                  # either -1 or port
                  type = lib.types.int;
                  default = -1;
                };
              };
            };
            default = { };
            description = ''
              The configuration of scheme. Set this field if using HTTPS.
            '';
          };
          log = mkEmptyFreeformOption ''
            The log configuration. Set this field to save detailed logs of disable.
          '';
          tasks = mkEmptyFreeformOption ''
            Configuration for background task threads.
          '';
          cors = mkEmptyFreeformOption ''
            Configuration for Cross-Origin Resource Sharing (CORS).
          '';
        };
      };
      default = { };
      description = ''
        Configuration for OpenList, see
        <link xlink:href="https://doc.oplist.org/configuration"/>
        for supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.optionalAttrs (cfg.user == defaultUser) {
      ${defaultUser} = {
        isSystemUser = true;
        inherit (cfg) group;
      };
    };

    users.groups = lib.optionalAttrs (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    networking.firewall.allowedTCPPorts =
      let
        mkIfExist = v: lib.mkIf (v != null) [ v ];

        inherit (cfg.settings) scheme;
      in
      lib.mkIf cfg.openFirewall (
        lib.mkMerge [
          (mkIfExist scheme.http_port)
          (lib.mkIf (scheme.https_port > 0) scheme.https_port)
        ]
      );

    systemd.services.openlist =
      let
        WorkingDirectory = "/var/lib/openlist";
        alistExe = lib.getExe cfg.package;
        confFile = format.generate "config.json" cfg.settings;
      in
      {
        description = "openlist service";
        after =
          let
            # WARN: IDK these services name are
            dbType = cfg.settings.database.type or null;
            opt = type: service: lib.optional (dbType == type) "${service}.service";
            optionalMysql = opt "mysql" "mysql";
            optionalPostgres = opt "postgres" "postgresql";
          in
          [ "network.target" ] ++ optionalMysql ++ optionalPostgres;
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p ${WorkingDirectory}/data
          cp ${confFile} ${WorkingDirectory}/data/config.json

          chmod 755 -R ${WorkingDirectory}/data/config.json

          export JWT_SECRET="$(head -n1 ${lib.escapeShellArg cfg.JWTSecretFile})"

          ${alistExe} server --data ${WorkingDirectory}/data
        '';
        postStart = ''
          ${alistExe} admin set "$(head -n1 ${lib.escapeShellArg cfg.adminPasswordFile})" --data ${WorkingDirectory}/data
        '';
        serviceConfig = {
          Restart = "on-failure";

          User = cfg.user;
          Group = cfg.group;

          StateDirectory = "openlist";
          StateDirectoryMode = "0750";
          RuntimeDirectory = "openlist";
          RuntimeDirectoryMode = "0750";

          inherit WorkingDirectory;
        };
      };
  };
}
