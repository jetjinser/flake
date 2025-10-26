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
    globalConfig = ''
      auto_https off
    '';
  };

  sops.secrets = lib.mkIf config.services.caddy.enable {
    karenina-key = {
      owner = config.services.caddy.user;
      inherit (config.services.caddy) group;
      mode = "0400";
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enable [
    80
    443
  ];
}
