{ config, lib, ... }:

{
  imports = [
    ../../modules/servicy
  ];

  servicy.haste-server.enable = true;

  services.cloudflared =
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
          note = 2718;
          box = 8000;
          hastebin = 8290;
          nvim = 9099;
        };
      };
    };
}
