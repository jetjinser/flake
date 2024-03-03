{ inputs
, pkgs
, lib
, ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
  ];

  sdImage.compressImage = true;

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxKernel.kernels.linux_6_7;
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  system.stateVersion = "24.05";
}
