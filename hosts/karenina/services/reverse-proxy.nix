{
  config,
  lib,
  ...
}:

let
  cfg = config.services.caddy;
in
{
  services.caddy = {
    enable = cfg.virtualHosts != { };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [
    80
    443
  ];
}
