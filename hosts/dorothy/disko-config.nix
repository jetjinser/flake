{
  flake,
  pkgs,
  config,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (config.users.users.${myself}) uid;
  inherit (config.users.groups.users) gid;
in
{
  imports = [
    flake.inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "ESP";
            end = "2G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            label = "ROOT";
            end = "-0";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                # https://github.com/Misterio77/nix-config/blob/a0bdad572f8e369e130b442a07dc2d50a96180c5/hosts/common/optional/ephemeral-btrfs.nix#L9-L31
                # dont understand btrfs
                # dont dare to apply the wipe on root
                "root" = {
                  # mountpoint = "/";
                  mountOptions = [ "compress=zstd" ];
                };
                "nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" ];
                };
                "tmp" = {
                  mountpoint = "/tmp";
                  mountOptions = [ "noatime" ];
                };
                "swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "noatime" ];
                  swap = {
                    swapfile.size = "24G";
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "mode=755"
        ];
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];

  users.users.${myself}.extraGroups = [ "fuse" ];
  programs.fuse.userAllowOther = true;
  system.fsPackages = [ pkgs.seaweedfs ];
  fileSystems."/srv/sfs" = {
    device = "fuse";
    fsType = "fuse./run/current-system/sw/bin/weed";
    options = [
      "filer=fs.2jk.pw:8888"
      "filer.path=/"
      "_netdev"
      "X-mount.owner=${myself}"
      "X-mount.group=users"
    ];
  };
  fileSystems."/srv/h" = {
    device = "fuse";
    fsType = "fuse./run/current-system/sw/bin/weed";
    options = [
      "_netdev"
      "filer=fs.2jk.pw:8888"
      "filer.path=/cold/h"
      "collection=h"
      "X-mount.owner=${myself}"
      "X-mount.group=users"
    ];
  };
}
