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
  services.transmission =
    let
      autoUnar = pkgs.writeShellApplication {
        name = "auto-unar";
        runtimeInputs = with pkgs; [
          bash
          findutils
          unar
        ];
        text = ''
          find /"$TR_TORRENT_DIR"/"$TR_TORRENT_NAME" \
            -type f -iregex '.*\.\(zip\|tar.bz\|rar\|tar.gz\|7z\)$' \
            -execdir bash -c 'unar "$0" && echo "would rm $0 when seeding done" || echo "failed: $0"' {} \;
        '';
      };
    in
    {
      enable = true;
      # TODO: migratory to transmission_4
      package = pkgs.transmission_3;
      openRPCPort = true;
      # on my local machine without public IP
      openPeerPorts = true;
      webHome = pkgs.flood-for-transmission;
      settings = {
        rpc-port = 9001;
        rpc-bind-address = "0.0.0.0";
        # only LAN
        rpc-whitelist = "127.0.0.1,192.168.*.*";
        download-dir = "/srv/store";
        rpc-username = myself;
        rpc-password = "{2b79a09b99bc2b99da06665666853bd337052a05ypW43WFG";
        ratio-limit-enabled = true;
        ratio-limit = 3.5; # uploaded / downloaded
        speed-limit-up-enabled = true;
        speed-limit-up = 350;
        speed-limit-down-enabled = false; # default: 100 KB/s

        script-torrent-done-enabled = true;
        script-torrent-done-filename = lib.getExe autoUnar;
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
