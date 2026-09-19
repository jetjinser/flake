{
  pkgs,
  modulesPath,
  flake,
  lib,
  ...
}:

{
  imports = [
    flake.inputs.nixos-hardware.nixosModules.raspberry-pi-4
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
  ];

  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  boot = {
    supportedFilesystems.zfs = lib.mkForce false;
    # use the vendored kernel from nixos-hardware raspberry-pi-4
    # (nixpkgs linuxPackages_rpi4 is deprecated and will be removed)
    kernelParams = [ "cma=64M" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
    raspberry-pi."4" = {
      fkms-3d.enable = true;
    };
    graphics.enable = true;
  };
}
