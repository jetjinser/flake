{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake.inputs) rockchip;
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  imports = with rockchip.nixosModules; [
    # sdImageRockchip
    dtOverlayPCIeFix
    # NOTE: ZFS is broken
    noZFS
  ];

  # rockchip.uBoot = rockchip.packages.${system}.uBootRock64;
  boot.kernelPackages = rockchip.legacyPackages.${system}.kernel_linux_latest_rockchip_stable;
}
