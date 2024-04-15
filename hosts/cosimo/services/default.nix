{ config
, lib
, pkgs
, ...
}:

let
  inherit (config.sops) secrets;

  mailerGroup = "mailer";

  icuUrl = "purejs.icu";
  orgUrl = "yeufossa.org";
in
{
  imports = [
    ../../../modules/servicy

    ./database.nix
    # TODO: need 25 port open
    # ./mailserver.nix
  ];

  users.groups.${mailerGroup} = {
    members = [ "wakapi" "forgejo" ];
  };

  servicy = {
    haste-server.enable = true;
    # statping-ng.enable = true;
    yarr = {
      enable = true;
      authFile = secrets.yarrAuth.path;
    };
    wakapi = {
      enable = true;
      group = mailerGroup;
      openFirewall = true;
      smtpPasswordFile = secrets.qcloudmailPWD.path;
      securityPasswordSaltFile = secrets.passwordSalt.path;
      settings = {
        app.support_contact = "aimer@purejs.icu";
        server = {
          port = 3990;
          public_url = "https://waka.yeufossa.org";
        };
        security = {
          insecure_cookies = false;
        };
        db = {
          dialect = "postgres";
          host = "/run/postgresql";
          port = 5432;
          user = "wakapi";
          name = "wakapi";
        };
        mail = {
          enabled = true;
          sender = "WakaYA <noreply@yeufossa.org>";
          provider = "smtp";
          smtp = {
            host = "smtp.qcloudmail.com";
            port = 456;
            username = "noreply@yeufossa.org";
            tls = true;
          };
        };
      };
    };
    alist = {
      enable = true;
      package = pkgs.callPackage ../../../modules/pkgs/alist.nix { };
      openFirewall = true;
      adminPasswordFile = secrets.alistPWD.path;
      JWTSecretFile = secrets.alistJWTSecret.path;
      settings = {
        site_url = "https://alist.purejs.icu";
        database = {
          type = "postgres";
          host = "/run/postgresql";
          port = 5432;
          user = "alist";
          name = "alist";
        };
        scheme = {
          http_port = 5667;
        };
      };
    };
  };

  services = {
    cloudflared =
      let
        IcuTunnelID = "473207d5-fc6b-44dc-a0fd-001db233e044";
        OrgTunnelID = "ad9c4187-ae3e-48f6-baf9-e66663e5e56b";

        serveIng = domain: subdomain: port: {
          "${subdomain}.${domain}" = "http://localhost:${toString port}";
        };

        serveIcuIng = serveIng icuUrl;
        serveOrgIng = serveIng orgUrl;
      in
      {
        enable = true;
        tunnels = {
          ${IcuTunnelID} = {
            credentialsFile = secrets.IcuTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveIcuIng {
              waka = 3990;
              alist = 5667;
              rss = 7070;
              # stats = 7133;
              hastebin = 8290;
            };
          };
          ${OrgTunnelID} = {
            credentialsFile = secrets.OrgTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveOrgIng {
              forgejo = 3000;
              status = 3001;
              waka = 3990;
              radicale = 5232;
              hastebin = 8290;
              social = 8889;
            };
          };
        };
      };

    forgejo = {
      enable = true;
      group = mailerGroup;
      mailerPasswordFile = secrets.qcloudmailPWD.path;
      settings = {
        DEFAULT = {
          # APP_NAME = "YEUFOSSA";
        };
        server = rec {
          DOMAIN = "forgejo.${orgUrl}";
          ROOT_URL = "https://${DOMAIN}/";
        };
        session.COOKIE_SECURE = true;
        log.LEVEL = "Warn";
        "ui.meta" = {
          AUTHOR = "Jinser Kafka";
          DESCRIPTION = "Something to be built";
        };
        service = {
          # ENABLE_NOTIFY_MAIL = true;
          REGISTER_EMAIL_CONFIRM = true;
        };
        mailer = {
          ENABLED = true;
          PROTOCOL = "smtps";
          SMTP_ADDR = "smtp.qcloudmail.com";
          SMTP_PORT = "465";
          USER = "noreply@yeufossa.org";
          FROM = "noreply@yeufossa.org";
        };
      };
      database.type = "postgres";
      dump = {
        enable = true;
        type = "tar.zst";
        interval = "04:25";
        backupDir = "/var/backup/forgejo";
      };
    };

    radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "127.0.0.1:5232" ];
        };
        auth = {
          type = "htpasswd";
          htpasswd_filename = "/etc/radicale/users";
          htpasswd_encryption = "bcrypt";
        };
        storage = {
          filesystem_folder = "/var/lib/radicale/collections";
        };
      };
    };

    akkoma = {
      enable = true;
      config = {
        ":tesla" = {
          ":adapter" = [ "Tesla.Adapter.Finch" ];
        };
        ":pleroma" = {
          "Pleroma.Web.Endpoint" = {
            url = {
              host = "social.yeufossa.org";
              scheme = "https";
            };
            http = {
              port = 8889;
              ip = "127.0.0.1";
            };
          };
          "Pleroma.User" = {
            restricted_nicknames = [ ];
          };
          "Pleroma.Emails.Mailer" = {
            enabled = true;
            adapter = "Swoosh.Adapters.SMTP";
            relay = "smtp.qcloudmail.com";
            username = "noreply@yeufossa.org";
            password_secret = secrets.qcloudmailPWD.path;
            port = 465;
            tls = true;
            auth = "if_available";
          };
          ":configurable_from_database" = false;
          ":instance" = {
            name = "social.yeufossa.org";
            email = "admin@yeufossa.org";
            notify_email = "noreply@yeufossa.org";
            # TODO:
            description = "TBD";
            registrations_open = false;
            invites_enabled = true;
            federating = false;
            allow_relay = true;
            public = false;
            # TODO:
            autofollowed_nicknames = [ ];
            healthcheck = true;
            # TODO:
            local_bubble = [ ];
            languages = [ "zh" "en" ];
            # TODO:
            export_prometheus_metrics = false;
          };
          ":welcome" = {
            # TODO:
            direct_message = {
              enabled = true;
              sender_nickname = "YEUFOSSA";
              message = "欢迎";
            };
          };
        };
      };
    };

    # gotosocial = {
    #   enable = true;
    #   settings = {
    #     application-name = "Pure Social";
    #     host = "social.${icuUrl}";
    #     bind-address = "127.0.0.1";
    #     db-address = "/var/lib/gotosocial/database.sqlite";
    #     db-type = "sqlite";
    #     port = 8889;
    #     protocol = "https";
    #     storage-local-base-path = "/var/lib/gotosocial/storage";
    #   };
    # };

    # INFO: disabled
    plausible = {
      enable = false;
      adminUser = {
        name = "jinser";
        email = "cmdr.jv@gmail.com";
        passwordFile = secrets.plausiblePWD.path;
        activate = true;
      };
      server = {
        port = 7133;
        baseUrl = "https://stats.${icuUrl}";
        secretKeybaseFile = secrets.plausibleSecretKeybase.path;
      };
    };

    uptime-kuma = {
      enable = true;
      settings = {
        # default
        # PORT = 3001;
      };
    };
  };
}
