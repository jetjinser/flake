{ lib, config, ... }:

let
  cfg = config.servicy.statping-ng;
in

with lib;
{
  options.servicy.statping-ng = {
    enable = mkEnableOption "Whether to enable statping-ng";

    database = {
      user = mkOption {
        type = types.str;
        default = "statping-ng";
        description = mdDoc "Database user.";
      };
      name = mkOption {
        type = types.str;
        default = "statping-ng";
        description = mdDoc "Database name.";
      };

      socket = mkOption {
        type = types.nullOr types.path;
        default = if cfg.database.createDatabase then "/run/postgresql" else null;
        defaultText = literalExpression "null";
        example = "/run/mysqld/mysqld.sock";
        description = mdDoc "Path to the unix socket file to use for authentication.";
      };

      createDatabase = mkOption {
        type = types.bool;
        default = true;
        description = mdDoc "Whether to create a local database automatically.";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      oci-containers = {
        backend = "podman";
        containers = {
          statping-ng = {
            image = "adamboutcher/statping-ng";
            ports = [ "8991:8080" ];
            volumes = [
              "${cfg.database.socket}:/run/postgresql"
              "/var/lib/statping-ng:/app"
            ];
          };
        };
      };
    };

    system.activationScripts.mkStatpingVarLib = lib.stringAfter [ "var" ] ''
      mkdir -p /var/lib/statping-ng
    '';

    systemd.services = {
      "${config.virtualisation.oci-containers.backend}-statping-ng" = {
        after = [ "postgresql.target" ];
      };
    };

    services.postgresql = mkIf cfg.database.createDatabase {
      enable = mkDefault true;

      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];

      authentication = ''
        local   ${cfg.database.name}   ${cfg.database.user}   scram-sha-256
      '';
    };
  };
}
