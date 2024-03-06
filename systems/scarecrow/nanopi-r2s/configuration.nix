{ inputs
, qkgs
, ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  nixpkgs.config.allowUnfree = true;
  sdImage = {
    compressImage = true;
    imageBaseName = "nixos-nanopi-r2s-rk3328";
    postBuildCommands = with qkgs; ''
      dd if=${ubootNanopiR2s}/idbloader.img of=$img conv=notrunc seek=64
      dd if=${ubootNanopiR2s}/u-boot.itb of=$img conv=notrunc seek=16384
    '';
  };

  system.stateVersion = "24.05";
}
