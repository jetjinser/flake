{
  inputs,
  ...
}:

# FIXME: need more power (boot knownledge)
# TODO: make it bootable with esp partition

{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.mmcblk0 = {
      type = "disk";
      device = "/dev/mmcblk0";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            priority = 1;
            label = "FIRMWARE";
            start = "1M";
            end = "128M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/firmware";
              mountOptions = [
                "nofail"
                "noauto"
              ];
            };
          };
          root = {
            label = "ROOT";
            end = "-0";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" ];
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
                    swapfile.size = "4G";
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
}
