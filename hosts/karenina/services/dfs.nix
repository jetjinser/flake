{
  config,
  lib,
  ...
}:

let
  cfg = config.services.seaweedfs;
  inherit (config.sops) secrets;

  enable = true;
  domain = "h.2jk.pw";
  master = [
    # "${cfg.master.ip}:${toString cfg.master.port}"
  ];
  peers = [
    "100.74.216.76:${toString cfg.master.port}"
  ];
in
{
  services.seaweedfs = {
    inherit enable;
    openFirewall = true;
    volume = {
      enable = true;
      ip = domain;
      ipBind = "100.80.144.122";
      master = master ++ peers;
      dataCenter = "UNI";
      rack = config.networking.hostName;
      disk = "external-ssd";
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    karenina-key = {
      owner = config.services.caddy.user;
      group = config.services.caddy.group;
      mode = "0400";
    };
  };
  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      ${domain} = {
        extraConfig = ''
          tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
          reverse_proxy http://127.0.0.1:${toString cfg.volume.port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
