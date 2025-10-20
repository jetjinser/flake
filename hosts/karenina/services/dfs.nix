{
  config,
  lib,
  ...
}:

let
  cfg = config.services.seaweedfs;
  inherit (config.sops) secrets;

  enable = true;
  domain = "anna.2jk.pw";
  ipBind = "100.80.144.122";
  master = [
    "127.0.0.1:${toString cfg.master.port}"
  ];
in
{
  services.seaweedfs = {
    inherit enable;
    openFirewall = true;
    master = {
      enable = true;
      ip = domain;
      inherit ipBind;
    };
    volume = {
      enable = true;
      ip = domain;
      inherit ipBind;
      master = master;
      dataCenter = "UNI";
      rack = config.networking.hostName;
      dataDir = "/srv/volume";
    };
    filer = {
      enable = true;
      ip = domain;
      inherit master ipBind;
      webdav.enable = true;
    };
  };

  sops.secrets = lib.mkIf (cfg.enable && config.services.caddy.enable) {
    karenina-key = {
      owner = config.services.caddy.user;
      inherit (config.services.caddy) group;
      mode = "0400";
    };
  };
  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      "dav.2jk.pw" = {
        extraConfig = ''
          tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
          reverse_proxy http://${ipBind}:${toString cfg.filer.webdav.port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
      "fs.2jk.pw" = {
        extraConfig = ''
          tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
          reverse_proxy http://${ipBind}:${toString cfg.filer.port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
