{
  config,
  lib,
  ...
}:

let
  cfg = config.services.openlist;

  inherit (config.sops) secrets;
  enable = true;
in
{
  sops.secrets = lib.mkIf cfg.enable {
    oplist-passwd = {
      owner = cfg.user;
      inherit (cfg) group;
      mode = "0400";
    };
  };
  services.openlist = {
    inherit enable;
    openFirewall = true;
    adminPasswordFile = secrets.oplist-passwd.path;
    settings = {
      s3.enable = true;
    };
  };
  # services.meilisearch = {
  #   enable = true;
  # };

  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      "list.2jk.pw" = {
        extraConfig = ''
          tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
          reverse_proxy http://127.0.0.1:${toString cfg.settings.scheme.http_port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
