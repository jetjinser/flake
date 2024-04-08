{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;

  statique = "statique.icu";
in
{
  services = {
    cloudflared =
      let
        StatiqueTunnelID = "a678f104-f65c-486b-9a55-f07ac00d70b8";

        serveIng = domain: subdomain: port: {
          "${subdomain}.${domain}" = "http://localhost:${toString port}";
        };

        serveStatiqueIng = serveIng statique;
      in
      {
        enable = true;
        tunnels = {
          ${StatiqueTunnelID} = {
            credentialsFile = secrets.statiqueTunnelJson.path;
            default = "http_status:404";
            ingress = lib.concatMapAttrs serveStatiqueIng
              {
                "*" = 8300;
              } // {
              "hello.statique.icu" = {
                service = "http://localhost:8300";
                originRequest.httpHostHeader = "statique.icu";
              };
            };
          };
        };
      };
  };
}
