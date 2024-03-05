{ pkgs
, inputs
, ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    kernelParams = [ "cma=64M" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };
}
