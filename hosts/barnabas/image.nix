{
  modulesPath,
  pkgs,
  config,
  lib,
  ...
}:

{
  imports = [
    (modulesPath + "/image/repart.nix")

    # implies `/profiles/minimal.nix`
    (modulesPath + "/profiles/image-based-appliance.nix")
  ];

  networking.hostName = "barnabas";
  system.nixos.distroName = "BarOS";
  system.image.id = "barnabas";

  boot.loader = {
    grub.enable = false;
    systemd-boot.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  # pick from https://github.com/NixOS/nixpkgs/pull/480005
  nixpkgs.overlays = [
    (_final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (_python-final: python-prev: {
          setuptools-rust = python-prev.setuptools-rust.overridePythonAttrs (_oldAttrs: {
            setupHook =
              if (lib.systems.equals pkgs.stdenv.hostPlatform pkgs.stdenv.targetPlatform) then
                null
              else
                prev.setupHook;
          });
        })
      ];
    })
  ];

  fileSystems =
    let
      inherit (config.image.repart) partitions;
    in
    {
      "/" = {
        fsType = "tmpfs";
        options = [ "size=100m" ];
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
      };
      "/nix/store" = {
        device = "/dev/disk/by-partlabel/${partitions.nix-store.repartConfig.Label}";
        fsType = "squashfs";
      };
      "/var" = {
        device = "/dev/disk/by-partlabel/var";
        fsType = "ext4";
      };
    };

  image.repart =
    let
      size = "1G";
      inherit (pkgs.stdenv.hostPlatform) efiArch;
    in
    {
      name = config.system.image.id;
      split = false;

      partitions = {
        boot = {
          contents = {
            "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
              "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";

            "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
              "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
          };
          repartConfig = {
            Type = "linux-generic";
            Label = "boot";
            Format = "vfat";
            SizeMinBytes = "200M";
            Flags = [ "esp" ];
            SplitName = "-";
          };
        };

        # A/B update (OTA)
        nix-store = {
          storePaths = [ config.system.build.toplevel ];
          nixStorePrefix = "/";
          repartConfig = {
            Type = "linux-generic";
            Label = "nix-store_${config.system.image.version}";
            Format = "squashfs";
            Minimize = "off";
            SizeMinBytes = size;
            SizeMaxBytes = size;
            ReadOnly = "yes";
            SplitName = "nix-store";
          };
        };
        empty.repartConfig = {
          Type = "linux-generic";
          Label = "_empty";
          Minimize = "off";
          SizeMinBytes = size;
          SizeMaxBytes = size;
          SplitName = "-";
        };
      };
    };

  boot.initrd.systemd.repart.enable = true;
  boot.initrd.systemd.repart.device = "/dev/mmcblk0";
  systemd.repart.partitions = {
    var = {
      Format = "ext4";
      Label = "var";
      Type = "var";
      Weight = 1000;
    };
  };
}
