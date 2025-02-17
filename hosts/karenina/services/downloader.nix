{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  cfg = config.services;
in
{
  services.transmission = {
    enable = true;
    openRPCPort = true;
    # on my local machine without public IP
    openPeerPorts = false;
    webHome = pkgs.flood-for-transmission;
    settings = {
      rpc-port = 9091;
      rpc-bind-address = "0.0.0.0";
      # only LAN
      rpc-whitelist = "127.0.0.1,192.168.*.*";
      download-dir = "/srv/store";
      rpc-username = myself;
      rpc-password = "{2b79a09b99bc2b99da06665666853bd337052a05ypW43WFG";
      ratio-limit-enabled = true;
      ratio-limit = 10.0;
      speed-limit-up-enabled = true;
      speed-limit-up = 350;
      speed-limit-down-enabled = false; # default: 100 KB/s
    };
  };

  systemd.tmpfiles.settings.downloaded = lib.mkIf cfg.transmission.enable {
    "${cfg.transmission.settings.download-dir}".d = {
      inherit (cfg.transmission) user;
      group = "users";
      mode = "0775";
    };
  };
}
