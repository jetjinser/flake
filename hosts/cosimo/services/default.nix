{
  flake,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services;

  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  bhu = "bhu.social";
  ccTunnelID = "cosimo-bhu";
in
{
  imports = importx ./. { } ++ [
    flake.config.modules.nixos.services
  ];

  sops.secrets = lib.mkIf cfg.cloudflared'.enable {
    ccTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
    # TODO: split from optional cloudflared'
    caddy = {
      sopsFile = ./secrets/caddy.env;
      format = "dotenv";
    };
  };
  services.cloudflared' = {
    tunnelID = ccTunnelID;
    domain = bhu;
    credentialsFile = secrets.ccTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };

  services.caddy = {
    enable = cfg.caddy.virtualHosts != { };
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-RLOwzx7+SH9sWVlr+gTOp5VKlS1YhoTXHV4k6r5BJ3U=";
    };
    environmentFile = secrets.caddy.path;
    virtualHosts."(tsnet)".extraConfig = ''
      @blocked not remote_ip 100.64.0.0/10

      tls {
        dns cloudflare {$CLOUDFLARE_API_TOKEN}
      }

      respond @blocked "Unauthorized" 403
    '';
  };

  networking.firewall.allowedTCPPorts = lib.mkIf cfg.caddy.enable [
    80
    443
  ];

  preservation.preserveAt."/persist" = {
    directories = [ "/var/lib" ];
  };
}
