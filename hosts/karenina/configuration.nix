{ inputs
, pkgs
, lib
, ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix"

    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  sdImage.compressImage = true;

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
    # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
    # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
    # On a Raspberry Pi 4 with 4 GB, you should either disable this parameter or increase to at least 64M if you want the USB ports to work.
    kernelParams = [ "cma=64M" ];
    loader = {
      # NixOS wants to enable GRUB by default
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  # https://github.com/NixOS/nixpkgs/issues/126755#issuecomment-869149243
  nixpkgs.overlays = [
    (_final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  system.stateVersion = "24.05";

  # https://discourse.nixos.org/t/flake-to-create-a-simple-sd-image-for-rpi4-cross/35185/24
  # Disabling the whole `profiles/base.nix` module, which is responsible
  # or adding ZFS and a bunch of other unnecessary programs:
  disabledModules = [
    "profiles/base.nix"
  ];

  # hardware.enableRedistributableFirmware = true;

  # boot = {
  #   loader = {
  #     grub.enable = false;
  #     generic-extlinux-compatible.enable = true;
  #   };

  #   consoleLogLevel = lib.mkDefault 7;
  #
  #   # The serial ports listed here are:
  #   # - ttyS0: for Tegra (Jetson TX1)
  #   # - ttyAMA0: for QEMU's -machine virt
  #   kernelParams =
  #     [ "console=ttyS0,115200n8" "console=ttyAMA0,115200n8" "console=tty0" ];

  # initrd.availableKernelModules = [
  #   # Allows early (earlier) modesetting for the Raspberry Pi
  #   "vc4"
  #   "bcm2835_dma"
  #   "i2c_bcm2835"
  #   # Allows early (earlier) modesetting for Allwinner SoCs
  #   "sun4i_drm"
  #   "sun8i_drm_hdmi"
  #   "sun8i_mixer"
  # ];

  # sdImage = {
  #   populateFirmwareCommands =
  #     let
  #       configTxt = pkgs.writeText "config.txt" ''
  #         [pi3]
  #         kernel=u-boot-rpi3.bin
  #         [pi4]
  #         kernel=u-boot-rpi4.bin
  #         enable_gic=1
  #         armstub=armstub8-gic.bin
  #         # Otherwise the resolution will be weird in most cases, compared to
  #         # what the pi3 firmware does by default.
  #         disable_overscan=1
  #         [all]
  #         # Boot in 64-bit mode.
  #         arm_64bit=1
  #         # U-Boot needs this to work, regardless of whether UART is actually used or not.
  #         # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
  #         # a requirement in the future.
  #         enable_uart=1
  #         # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
  #         # when attempting to show low-voltage or overtemperature warnings.
  #         avoid_warnings=1
  #       '';
  #     in
  #     ''
  #       (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
  #       # Add the config
  #       cp ${configTxt} firmware/config.txt
  #       # Add pi3 specific files
  #       cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin
  #       # Add pi4 specific files
  #       cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
  #       cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
  #       cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
  #     '';
  #   populateRootCommands = ''
  #     mkdir -p ./files/boot
  #     ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  #   '';
  # };
}
