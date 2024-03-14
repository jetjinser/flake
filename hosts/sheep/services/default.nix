{ lib
, config
, ...
}:

let
  inherit (config.sops) secrets;

  atticdName = "cache";
  atticdPort = "5688";

  orgUrl = "yeufossa.org";
in
{
  imports = [
    (import ./cacheServer.nix {
      credentialsFile = secrets.AtticCredentialsEnv.path;
      inherit atticdName atticdPort orgUrl;
    })
    (import ./hydraOr.nix)
  ];

  services = {
    cloudflared =
      let
        IcuTunnelID = "dc88ef64-73e2-452c-a8fa-aef341fccf1c";

        serveIng = domain: subdomain: port: {
          "${subdomain}.${domain}" = "http://localhost:${toString port}";
        };

        serveIcuIng = serveIng orgUrl;
      in
      {
        enable = true;
        tunnels = {
          ${IcuTunnelID} = {
            credentialsFile = secrets.SpOrgTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveIcuIng {
              ${atticdName} = atticdPort;
              typhon = 3000;
            };
          };
        };
      };
  };
}
