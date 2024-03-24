{ orgUrl
, atticdName
, atticdPort
}:

{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
in
{
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
            ingress = (lib.concatMapAttrs serveIcuIng
              {
                ${atticdName} = atticdPort;
                pgs = 8300;
                # typhon = 3000;
              }) // {
              "pgs.yeufossa.org" = "tcp://localhost:2222";
            };
          };
        };
      };
  };
}
