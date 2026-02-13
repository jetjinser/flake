{
  modulesPath,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64-new-kernel.nix"
    ../../modules/nixosModules/system-tarball-extlinux.nix
  ];

  sdImage = {
    imageBaseName = "nanopi-r2s";
    postBuildCommands =
      let
        # TODO: modular packages
        ubootNanopiR2s = pkgs.callPackage ../../packages/uboot-nanopi-r2s {
          inherit (pkgs) armTrustedFirmwareRK3328;
        };
      in
      ''
        dd if=${ubootNanopiR2s}/idbloader.img of=$img conv=notrunc seek=64
        dd if=${ubootNanopiR2s}/u-boot.itb of=$img conv=notrunc seek=16384
      '';
  };

  # NOTE: broken
  boot.supportedFilesystems.zfs = lib.mkForce false;

  system.enableExtlinuxTarball = true;
}
