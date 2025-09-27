{
  config,
  lib,
  ...
}:

let
  enable = true;
  domain = "h.2jk.pw";

  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  cfg = config.services.home-assistant;
in
{
  services.home-assistant = {
    inherit enable;
    config = {
      http = {
        base_url = "http://${domain}";
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
      homeassistant = {
        name = hostName;
        unit_system = "metric";
      };
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    ha-key = {
      owner = config.services.caddy.user;
      inherit (config.services.caddy) group;
      mode = "0400";
    };
  };
  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      ${domain} = {
        extraConfig = ''
          tls ${../../../assets/ha.crt} ${secrets.ha-key.path}
          reverse_proxy http://127.0.0.1:${toString cfg.config.http.server_port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
