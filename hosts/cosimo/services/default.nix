{ config, lib, pkgs, ... }:

let
  inherit (config.sops) secrets;

  mailerGroup = "mailer";

  icuUrl = "purejs.icu";
  orgUrl = "yeufossa.org";
in
{
  imports = [
    ../../../modules/servicy

    ./mailserver.nix
  ];

  users.groups.${mailerGroup} = {
    members = [ "wakapi" "forgejo" ];
  };

  services.postgresql = {
    enable = true;

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

    # INFO: disabled
    homepage-dashboard = {
      enable = false;
      openFirewall = true;
      configPath = pkgs.writeText "settings.yaml" (
        builtins.toJSON {
          titile = "jinser | 临时标题";
          background = {
            image =
              "${pkgs.nixos-artwork.wallpapers.nineish}/share/backgrounds/nixos/nix-wallpaper-simple-red.png";
            blur = "sm";
          };
          favicon = "https://www.purejs.icu/favicon/favicon-32x32.png";
        }
      );
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
              status = 3001;
              radicale = 5232;
              alist = 5667;
              rss = 7070;
              # stats = 7133;
              hastebin = 8290;
              social = 8889;
            };
          };
          ${OrgTunnelID} = {
            credentialsFile = secrets.OrgTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveOrgIng {
              forgejo = 3000;
              waka = 3990;
              # www = 8082;
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
        interval = "04:31";
      };
    };

    radicale = {
      enable = true;
      settings = {
        server = {
          hosts = [ "0.0.0.0:5232" "[::]:5232" ];
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

    gotosocial = {
      enable = true;
      settings = {
        application-name = "Pure Social";
        host = "social.${icuUrl}";
        bind-address = "127.0.0.1";
        db-address = "/var/lib/gotosocial/database.sqlite";
        db-type = "sqlite";
        port = 8889;
        protocol = "https";
        storage-local-base-path = "/var/lib/gotosocial/storage";
      };
    };

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
