{
  lib,
  config,
  ...
}:

let
  enable = true;

  cfg = config.services.searx;
in
{
  services.searx = {
    inherit enable;
    settings = {
      use_default_settings = true;

      server.port = 19002;
      server.bind_address = "mie.2jk.pw";

      server.secret_key = "dummy";

      outgoing.proxies = {
        "all://" = [ config.networking.proxy.default ];
      };
    };
  };

  services.caddy.virtualHosts = lib.mkIf cfg.enable {
    "search.bhu.social".extraConfig = ''
      import tsnet
      reverse_proxy http://${cfg.settings.server.bind_address}:${toString cfg.settings.server.port} {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';
  };
}
