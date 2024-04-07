{ flake
, ...
}:

{
  imports = [
    flake.inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            type = "EF02";
            label = "BOOT";
            start = "0";
            end = "+1M";
          };
          root = {
            label = "ROOT";
            end = "-0";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "boot" = {
                  mountpoint = "/boot";
                  mountOptions = [ "compress=zstd" ];
                };
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
                    swapfile.size = "8G";
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
        mountOptions = [ "defaults" "mode=755" ];
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/mnt/mie" = {
    device = "192.168.114.3:/mnt/2t/jinser/Z/0Sm93J+8mHl8K8M5nsQ1wvFOMEGILgldNFxnL6aSo=";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.idle-timeout=600" ];
  };

  swapDevices = [
    { device = "/swap/swapfile"; }
  ];
}
