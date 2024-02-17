{ config, lib, ... }:

{
  imports = [
    ../../modules/servicy
  ];

  servicy = {
    haste-server.enable = true;
    statping-ng.enable = true;
    yarr = {
      enable = true;
      authFile = config.sops.secrets.yarrAuth.path;
    };
  };

  services = {
    cloudflared =
      let
        tunnelID = "473207d5-fc6b-44dc-a0fd-001db233e044";
        serveIng = subdomain: port: {
          "${subdomain}.purejs.icu" = "http://localhost:${toString port}";
        };
      in
      {
        enable = true;
        tunnels.${tunnelID} = {
          credentialsFile = config.sops.secrets.tunnelJson.path;
          default = "http_status:404";
          ingress = lib.concatMapAttrs serveIng {
            forgejo = 3000;
            radicale = 5232;
            rss = 7070;
            # stats = 7133;
            hastebin = 8290;
            social = 8889;
            status = 8991;
          };
        };
      };

    forgejo = {
      enable = true;
      settings.server = rec {
        DOMAIN = "forgejo.purejs.icu";
        ROOT_URL = "https://${DOMAIN}/";
      };
      database.type = "postgres";
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
        host = "social.purejs.icu";
        bind-address = "127.0.0.1";
        db-address = "/var/lib/gotosocial/database.sqlite";
        db-type = "sqlite";
        port = 8889;
        protocol = "https";
        storage-local-base-path = "/var/lib/gotosocial/storage";
      };
    };

    # XXX: disabled
    plausible = {
      enable = false;
      adminUser = {
        name = "jinser";
        email = "cmdr.jv@gmail.com";
        passwordFile = config.sops.secrets.plausiblePWD.path;
        activate = true;
      };
      server = {
        port = 7133;
        baseUrl = "https://stats.purejs.icu";
        secretKeybaseFile = config.sops.secrets.plausibleSecretKeybase.path;
      };
    };
  };
}
