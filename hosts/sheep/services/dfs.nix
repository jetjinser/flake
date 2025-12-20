{
  config,
  ...
}:

let
  cfg = config.services.seaweedfs;

  enable = false;
  domain = "mie.2jk.pw";
  ipBind = "0.0.0.0";
  master = [
    "anna.2jk.pw:${toString cfg.master.optionsCLI.port}"
  ];
in
{
  services.seaweedfs = {
    inherit enable;
    openFirewall = true;
    volume = {
      enable = true;
      optionsCLI = {
        ip = domain;
        mserver = master;
        "ip.bind" = ipBind;
        dataCenter = "MIE";
        rack = config.networking.hostName;
        dir = "/vol.data";
        "dir.idx" = "/vol.meta";
        # disk = "ssd";
        max = 128;
      };
    };
  };
}
