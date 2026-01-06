{
  flake,
  pkgs,
  lib,
  ...
}:

let
  enable = false;

  inherit (flake.config.symbols.people) myself;

  staging-dir = "/srv/staging";
  flattend-zip-dir = "/srv/zips";
in
{
  config = lib.mkIf enable {

    users.users.${myself}.extraGroups = [ "fuse" ];
    programs.fuse.userAllowOther = true;
    system.fsPackages = [ pkgs.seaweedfs ];

    systemd.services.sing-box.before = [
      "srv-staging.mount"
    ];
    fileSystems."/srv/staging" = {
      device = "fuse";
      fsType = "fuse./run/current-system/sw/bin/weed";
      options = [
        "_netdev"
        "filer=fs.2jk.pw:8888"
        "filer.path=/staging"
        "collection=h"
        "cacheCapacityMB=1024"
        "X-mount.owner=${myself}"
        "X-mount.group=users"
      ];
    };
    systemd.automounts = [
      { where = "/srv/staging"; }
    ];

    systemd.services.mount-all-zips =
      let
        mountAllZips = pkgs.writeShellApplication {
          name = "mount-all-zips";
          runtimeInputs = with pkgs; [
            mount-zip
            fuse
          ];
          text = ''
            WATCH_DIR="${staging-dir}"
            MOUNT_BASE="${flattend-zip-dir}"
            ls "$WATCH_DIR"/*.zip

            mkdir -p "$MOUNT_BASE"
            # not working actually:
            # always `fusermount: failed to unmount /srv/zips: Operation not permitted`
            fusermount -u "$MOUNT_BASE" || true
            mount-zip -o allow_other -o auto_unmount -o redact -o nomerge "$WATCH_DIR"/*.zip "$MOUNT_BASE"

            echo "done"
          '';
        };
      in
      {
        description = "Mount all zip files in ${staging-dir}";
        serviceConfig = {
          Type = "oneshot";
          User = myself;
          Group = "users";
          ExecStart = "${mountAllZips}/bin/mount-all-zips";
          PrivateMounts = false;
          RemainAfterExit = true;
        };
      };
    # systemd.paths.mount-all-zips = {
    #   description = "Watch for zip files in ${staging-dir}";
    #   pathConfig = {
    #     PathChanged = "${staging-dir}";
    #     PathExistsGlob = "${staging-dir}/*.zip";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
  };
}
