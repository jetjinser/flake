{
  lib,
  config,
  ...
}:

let
  enable = true;

  inherit (config.networking) hostName;
  cfg = config.services.beszel.hub;
in
{
  services.beszel.hub = {
    inherit enable;
    port = 19003;
    host = hostName;
  };

  services.caddy.virtualHosts = lib.mkIf cfg.enable {
    "hub.2jk.pw" = {
      extraConfig = ''
        import tsnet
        reverse_proxy http://${cfg.host}:${toString cfg.port} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };
}
