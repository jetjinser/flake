{
  lib,
  config,
  ...
}:

let
  cfg = config.services.magnetico;
  inherit (config.sops) secrets;

  enable = true;
in
{
  services.magnetico = {
    inherit enable;
    web.port = 9008;
  };
  networking.firewall.allowedUDPPorts = [ cfg.crawler.port ];

  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      "mn.2jk.pw".extraConfig = ''
        tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
        reverse_proxy http://${cfg.web.address}:${toString cfg.web.port} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };
}
