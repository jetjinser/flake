{
  flake,
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services;

  # FIXME: Wrong inclusion of `mc/jvmOpts`, `mc/properties`, `mc/p1.nix`
  #        broken on nested directories
  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  twojk = "2jk.pw";
  tunnelID = "sheep-2jk";
in
{
  imports = (importx ./. { }) ++ [
    flake.config.modules.nixos.services
  ];

  sops.secrets = lib.mkMerge [
    (lib.mkIf cfg.caddy.enable {
      caddy = {
        sopsFile = ./secrets/caddy.env;
        format = "dotenv";
      };
    })
    (lib.mkIf cfg.cloudflared'.enable {
      tunnelJson = { };
      originCert.owner = users.cloudflared-dns.name;
    })
  ];

  services.cloudflared' = {
    inherit tunnelID;
    domain = twojk;
    credentialsFile = secrets.tunnelJson.path;
    certificateFile = secrets.originCert.path;
  };

  services.caddy = {
    enable = cfg.caddy.virtualHosts != { };
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
      hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
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
