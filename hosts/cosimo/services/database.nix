{ lib
, config
, ...
}:

let
  enable = true;

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
        inherit enable;

        inherit ensureDatabases ensureUsers;
      };
    postgresqlBackup = {
      inherit enable;

      startAt = "*-*-* 04:15:00";
      location = "/var/backup/postgresql";
      compression = "zstd";
      compressionLevel = 10;
      backupAll = true;
    };

    restic = {
      server = {
        enable = true;
        listenAddress = ":9876";
        dataDir = "/var/lib/restic";
      };
      backups = lib.mkIf enable (
        let
          user = "restic";

          passwordFile = secrets.resticPWD.path;

          timerConfig = {
            OnCalendar = "04:25";
            Persistent = true;
          };

          backupPaths = [
            "/var/lib/forgejo/dump"
            "/var/backup/postgresql"
          ];
        in
        {
          localBackup = {
            inherit user passwordFile timerConfig;

            initialize = true;
            paths = backupPaths;
            repository = "/var/lib/restic";
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

  users = {
    users.restic = {
      isSystemUser = true;
      group = "restic";
    };
    groups.restic = { };
  };

}
