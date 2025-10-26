{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
  cfg = config.services.transmission;
  inherit (config.sops) secrets;
  inherit (flake.config.symbols.people) myself;

  enable = true;
  download-dir = "/srv/t";
  flattend-zip-dir = "/srv/zips";
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
      inherit enable;
      package = pkgs.transmission_4;
      openRPCPort = true;
      # on my local machine without public IPv4 IP
      openPeerPorts = true;
      webHome = pkgs.flood-for-transmission;
      settings = {
        rpc-port = 9001;
        rpc-bind-address = "127.0.0.1";
        rpc-whitelist-enabled = false;
        rpc-username = myself;
        rpc-password = "{2b79a09b99bc2b99da06665666853bd337052a05ypW43WFG";
        rpc-authentication-required = true;

        inherit download-dir;
        download-queue-size = 10; # default to 5
        incomplete-dir-enabled = true;
        ldp-enabled = true;
        start-added-torrents = false;

        speed-limit-up-enabled = true;
        speed-limit-up = 800; # 800 KB/s
        alt-speed-enabled = true;
        alt-speed-up = 450; # 450 KB/s
        alt-speed-down = 10000000; # 10 GB/s
        alt-speed-time-enabled = true;
        alt-speed-time-begin = 480; # 8 AM
        lat-speed-time-end = 60; # 1 AM

        script-torrent-done-enabled = false;
        script-torrent-done-filename = lib.getExe autoUnar;

        # 0 = Prefer unencrypted connections
        # 1 = Prefer encrypted connections
        # 2 = Require encrypted connections;
        # default = 1
        # Encryption may help get around some ISP filtering,
        # but at the cost of slightly higher CPU use
        # > Xunlei does not have enc
        encryption = 2;
      };
    };

  systemd.tmpfiles.settings.downloaded = lib.mkIf cfg.enable {
    "${cfg.settings.download-dir}".d = {
      inherit (cfg) user;
      group = "users";
      mode = "0775";
    };
  };

  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      "tm.2jk.pw".extraConfig = ''
        tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
        reverse_proxy http://${cfg.settings.rpc-bind-address}:${toString cfg.settings.rpc-port} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
      "ltm.2jk.pw".extraConfig = ''
        tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
        reverse_proxy http://${cfg.settings.rpc-bind-address}:${toString cfg.settings.rpc-port} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };

  systemd.services.mount-all-zips =
    let
      mountAllZips = pkgs.writeShellApplication {
        name = "mount-all-zips";
        runtimeInputs = with pkgs; [
          mount-zip
          fuse
        ];
        text = ''
          WATCH_DIR="${download-dir}"
          MOUNT_BASE="${flattend-zip-dir}"
          ls "$WATCH_DIR"

          mkdir -p "$MOUNT_BASE"
          # not working actually:
          # always `fusermount: failed to unmount /srv/zips: Operation not permitted`
          fusermount -u "$MOUNT_BASE" || true
          mount-zip -o auto_unmount -o redact -o nomerge "$WATCH_DIR"/*.zip "$MOUNT_BASE"

          echo "done"
        '';
      };
    in
    {
      description = "Mount all zip files in ${download-dir}";
      serviceConfig = {
        Type = "oneshot";
        User = myself;
        Group = "users";
        ExecStart = "${mountAllZips}/bin/mount-all-zips";
        PrivateMounts = false;
        RemainAfterExit = true;
      };
    };
  systemd.paths.mount-all-zips = {
    description = "Watch for zip files in ${download-dir}";
    pathConfig.PathExistsGlob = "${download-dir}/*.zip";
    wantedBy = [ "multi-user.target" ];
  };
}
