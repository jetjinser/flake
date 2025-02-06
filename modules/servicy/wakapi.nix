{
  config,
  pkgs,
  lib,
  ...
}:

let
  defaultUser = "wakapi";
  cfg = config.servicy.wakapi;
  format = pkgs.formats.yaml { };

  mkEnabledOption =
    description:
    lib.mkOption {
      type = lib.types.bool;
      default = true;
      inherit description;
    };
  mkEmptyStringOption =
    description:
    lib.mkOption {
      type = lib.types.str;
      default = "";
      inherit description;
    };
in
{
  options.servicy.wakapi = {
    enable = lib.mkEnableOption (lib.mdDoc "Whether to enable wakapi.");

    package = lib.mkPackageOption pkgs "wakapi" { };

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

    openFirewall = lib.mkEnableOption "Open ports in the firewall for wakapi.";

    smtpPasswordFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "SMTP server authentication password file path.";
    };

    securityPasswordSaltFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = "Pepper to use for password hashing.";
    };

    settings =
      let
        appOptions = {
          leaderboard_enabled = mkEnabledOption "Whether to enable the public leaderboard.";
          leaderboard_scope = lib.mkOption {
            type = lib.types.enum [
              "24_hours"
              "week"
              "month"
              "year"
              "7_days"
              "14_days"
              "30_days"
              "6_months"
              "12_months"
              "all_time"
            ];
            default = "7_days";
            description = "Aggregation interval for public leaderboard.";
          };
          import_enabled = mkEnabledOption "Whether data imports from WakaTime or other Wakapi instances are permitted.";
          support_contact = lib.mkOption {
            type = lib.types.str;
            default = "hostmaster@wakapi.dev";
            description = "E-Mail address to display as a support contact on the page.";
          };
        };
        serverOptions = {
          port = lib.mkOption {
            type = lib.types.port;
            default = 3000;
            description = "Port to listen on.";
          };
          listen_ipv4 = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "IPv4 network address to listen on (set to '-' to disable IPv4).";
          };
          listen_ipv6 = lib.mkOption {
            type = lib.types.str;
            default = "::1";
            description = "IPv6 network address to listen on (set to '-' to disable IPv6).";
          };
          listen_socket = mkEmptyStringOption "UNIX socket to listen on (set to '-' to disable UNIX socket).";

          public_url = lib.mkOption {
            type = lib.types.str;
            default = "http://localhost:3000";
            description = "URL at which your Wakapi instance can be found publicly.";
          };
        };
        securityOptions = {
          allow_signup = mkEnabledOption "Whether to enable user registration.";
          disable_frontpage = lib.mkEnableOption "Whether to disable landing page (useful for personal instances).";
          expose_metrics = lib.mkEnableOption (
            lib.mdDoc "Whether to expose Prometheus metrics under /api/metrics`"
          );
        };
        dbOptions = {
          host = mkEmptyStringOption "Database host.";
          port = lib.mkOption {
            type = with lib.types; nullOr port;
            default = null;
            description = "Database port.";
          };
          socket = mkEmptyStringOption "Database UNIX socket (alternative to host) (for MySQL only).";
          user = mkEmptyStringOption "Database user.";
          password = mkEmptyStringOption "Database password.";
          name = lib.mkOption {
            type = lib.types.str;
            default = "wakapi_db.db";
            description = "Database name.";
          };
          dialect = lib.mkOption {
            type = lib.types.enum [
              "sqlite3"
              "mysql"
              "postgres"
              "cockroach"
              "mssql"
            ];
            default = "sqlite3";
            description = lib.mdDoc ''
              Database type (one of `sqlite3`, `mysql`, `postgres`, `cockroach`, `mssql`).
            '';
          };
        };
        mailOptions =
          let
            smtpOptions = {
              host = mkEmptyStringOption "SMTP server address for sending mail (if using smtp mail provider).";
              port = lib.mkOption {
                type = with lib.types; nullOr port;
                default = null;
                description = "SMTP server port (usually 465).";
              };
              username = mkEmptyStringOption "SMTP server authentication username";

              tls = lib.mkEnableOption (
                lib.mdDoc ''
                  Whether the SMTP server requires TLS encryption (`false` for STARTTLS or no encryption).
                ''
              );
            };
          in
          {
            enabled = mkEnabledOption "Whether to allow Wakapi to send e-mail (e.g. for password resets).";
            sender = lib.mkOption {
              type = lib.types.str;
              default = "Wakapi <noreply@wakapi.dev>";
              description = "Default sender address for outgoing mails.";
            };
            provider = lib.mkOption {
              type = lib.types.enum [ "smtp" ];
              default = "smtp";
              description = "Implementation to use for sending mails.";
            };

            smtp = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;

                options = smtpOptions;
              };
            };
          };
      in
      lib.mkOption {
        type = lib.types.submodule {
          freeformType = format.type;

          options = {
            env = lib.mkOption {
              type = lib.types.str;
              default = "production";
              description = "Whether to use development or production settings.";
            };
            app = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;
                options = appOptions;
              };
              default = { };
            };
            server = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;
                options = serverOptions;
              };
              default = { };
            };
            security = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;
                options = securityOptions;
              };
              default = { };
            };
            db = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;
                options = dbOptions;
              };
              default = { };
            };
            mail = lib.mkOption {
              type = lib.types.submodule {
                freeformType = format.type;
                options = mailOptions;
              };
              default = { };
            };
          };
        };
        default = { };
        description = ''
          Configuration for wakapi, see
          <link xlink:href="https://github.com/muety/wakapi#-configuration-options"/>
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

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.server.port ];

    systemd.services.wakapi = {
      description = "wakapi service";
      after =
        let
          # WARN: IDK these services name are
          dbDialect = cfg.settings.db.dialect;
          opt = type: service: lib.optional (dbDialect == type) "${service}.service";
          optionalMysql = opt "mysql" "mysql";
          optionalPostgres = opt "postgres" "postgresql";
          optionalCockroach = opt "cockroach" "cockroach";
          optionalMssql = opt "mssql" "mssql";
        in
        [ "network.target" ] ++ optionalMysql ++ optionalPostgres ++ optionalCockroach ++ optionalMssql;
      wantedBy = [ "multi-user.target" ];
      script =
        let
          wakapiExe = lib.getExe cfg.package;
          confFile = format.generate "wakapi.yaml" cfg.settings;
        in
        ''
          ${lib.optionalString (cfg.settings.mail.provider == "smtp") ''
            export WAKAPI_MAIL_SMTP_PASS="$(head -n1 ${lib.escapeShellArg cfg.smtpPasswordFile})"
          ''}
          export WAKAPI_PASSWORD_SALT="$(head -n1 ${lib.escapeShellArg cfg.securityPasswordSaltFile})"

          ${wakapiExe} -config ${confFile}
        '';
      serviceConfig = {
        Restart = "on-failure";

        User = cfg.user;
        Group = cfg.group;

        StateDirectory = "wakapi";
        StateDirectoryMode = "0750";
        RuntimeDirectory = "wakapi";
        RuntimeDirectoryMode = "0750";

        WorkingDirectory = "/var/lib/wakapi";
      };
    };
  };
}
