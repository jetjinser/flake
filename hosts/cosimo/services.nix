{ config, lib, ... }:

{
  imports = [
    ../../modules/servicy
  ];

  servicy = {
    haste-server.enable = true;
    statping-ng.enable = true;
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
            # note = 2718;
            # box = 8000;
            hastebin = 8290;
            # nvim = 9099;
            forgejo = 3000;
            radicale = 5232;
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
  };
}
