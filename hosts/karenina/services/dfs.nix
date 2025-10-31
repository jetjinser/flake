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
  ipBind = "0.0.0.0";
  master = [
    "127.0.0.1:${toString cfg.master.optionsCLI.port}"
  ];
in
{
  services.seaweedfs = {
    inherit enable;
    openFirewall = true;
    settings = {
      master = {
        master.maintenance = {
          scripts = ''
            lock
            ec.encode -fullPercent=95 -quietFor=1h
            ec.rebuild -force
            ec.balance -force
            volume.deleteEmpty -quietFor=24h -force
            volume.balance -force
            volume.fix.replication -force
            s3.clean.uploads -timeAgo=24h
            unlock
          '';
          sleep_minutes = 17;
        };
      };
    };
    master = {
      enable = true;
      optionsCLI = {
        ip = domain;
        "ip.bind" = ipBind;
        # 1GB
        volumeSizeLimitMB = 1024;
        volumePreallocate = true;
      };
    };
    volume = {
      enable = true;
      optionsCLI = {
        ip = domain;
        inherit master;
        "ip.bind" = ipBind;
        dataCenter = "UNI";
        rack = config.networking.hostName;
        dir = "/srv/data/seaweedfs/volume";
        max = 30;
      };
    };
    filer = {
      enable = true;
      optionsCLI = {
        ip = domain;
        inherit master;
        "ip.bind" = ipBind;
        # s3 = true;
        webdav = true;
        "webdav.collection" = "h";
        "webdav.filer.path" = "/staging";
        dataCenter = "UNI";
        rack = config.networking.hostName;
        encryptVolumeData = true;
      };
    };
  };

  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      "fs.2jk.pw" = {
        extraConfig = ''
          tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
          reverse_proxy http://${ipBind}:${toString cfg.filer.optionsCLI.port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
      "http://dav.2jk.pw" = {
        extraConfig = ''
          reverse_proxy http://${ipBind}:${toString cfg.filer.optionsCLI."webdav.port"} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
