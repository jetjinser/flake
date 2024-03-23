{ lib
, config
, ...
}:

# FIXME: restic 没整明白

let
  enable = false;

  inherit (config.sops) secrets;
in
{
  services = {
    postgresql =
      let
        ensureDatabases = [ "wakapi" "alist" "uptime-kuma" ];
        ensureUsers = [
          {
            name = "wakapi";
            ensureDBOwnership = true;
          }
          {
            name = "alist";
            ensureDBOwnership = true;
          }
          {
            name = "uptime-kuma";
            ensureDBOwnership = true;
          }
        ];
      in
      {
        # inherit enable;
        # HACK: Ad-Hoc
        enable = true;

        inherit ensureDatabases ensureUsers;
      };
    restic = {
      backups = lib.mkIf enable (
        let
          user = "restic";

          passwordFile = secrets.resticPWD.path;

          timerConfig = {
            OnCalendar = "04:35";
            Persistent = true;
          };

          backupPaths = [
            "/var/backup/forgejo"
            "/var/backup/postgresql"
          ];
        in
        {
          localBackup = {
            inherit user passwordFile timerConfig;

            initialize = true;
            paths = backupPaths;
            repository = "/var/backup/restic";
          };
          webdavBackup = {
            inherit user passwordFile timerConfig;

            rcloneConfigFile = secrets.rcloneConf.path;

            paths = backupPaths;
            repository = "rclone:dav:/";
          };
        }
      );
    };
  };

  users = lib.mkIf enable {
    users.restic = {
      isSystemUser = true;
      group = "backup";
    };
    groups.backup = {
      members = [ "postgres" ];
    };
  };

  servicy.postgresqlBackup = {
    inherit enable;

    user = "postgres";
    group = "backup";

    startAt = "*-*-* 04:15:00";
    location = "/var/backup/postgresql";
    compression = "zstd";
    compressionLevel = 10;
    backupAll = true;
  };
}
