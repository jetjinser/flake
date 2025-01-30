{ lib
, config
, ...
}:

let
  inherit (config.services.grafana) settings;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  statique = "statique.icu";
  subdomain = "observer";
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        enable_gzip = true;
        enforce_domain = true;
        domain = "${subdomain}.${statique}";
      };
    };

    sops.secrets = {
      statiqueTunnelJson.owner = users.cloudflared.name;
    };
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
          tunnels = {
            ${StatiqueTunnelID} = {
              credentialsFile = secrets.statiqueTunnelJson.path;
              default = "http_status:404";
              ingress = lib.concatMapAttrs serveStatiqueIng {
                ${subdomain} = settings.server.http_port;
              };
            };
          };
        };
    };
  };

}
