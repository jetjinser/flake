{ inputs
, pkgs
, ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-new-kernel-no-zfs-installer.nix"
  ];

  nixpkgs.config.allowUnfree = true;
  sdImage = {
    compressImage = true;
    imageBaseName = "nixos-nanopi-r2s-rk3328";
    postBuildCommands = with pkgs; ''
      dd if=${ubootRock64}/idbloader.img of=$img conv=fsync,notrunc bs=512 seek=64
      dd if=${ubootRock64}/u-boot.itb of=$img conv=fsync,notrunc bs=512 seek=16384
    '';
  };

  systemd.services."hardware-setup" = {
    enable = true;
    script = ''
      # enable USB power (this is a hack compensating for the wrong device tree)
      ${pkgs.libgpiod}/bin/gpioset 1 26=1
      # initialize IR protocol handlers
      ${pkgs.v4l-utils.override{withGUI = false;}}/bin/ir-keytable -p rc-5 -p rc-5-sz -p jvc -p sony -p nec -p sanyo -p mce_kbd -p rc-6 -p sharp -p xmp -p imon -p rc-mm
    '';
    wantedBy = [ "default.target" ];
    serviceConfig = {
      RestartSec = 1;
      Restart = "on-failure";
    };
  };

  system.stateVersion = "24.05";
}