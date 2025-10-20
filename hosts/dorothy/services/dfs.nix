{
  config,
  ...
}:

let
  enable = false;

  cfg = config.services.seaweedfs;
  ip = "127.0.0.1";
  master = [ "127.0.0.1:${toString cfg.master.port}" ];
in
{
  services.seaweedfs = {
    inherit enable;
    openFirewall = true;
    master = {
      enable = true;
      inherit ip;
      ipBind = "0.0.0.0";
    };
    filer = {
      enable = true;
      inherit ip master;
      ipBind = "0.0.0.0";
      webdav.enable = true;
    };
  };
}
