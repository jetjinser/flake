{
  modulesPath,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # flake.self.nixosModules.barnabas

    (modulesPath + "/profiles/perlless.nix")

    ./image.nix
    ./rockchip.nix
    ./networking.nix
    ../share/cloud

    # ./configuration.nix
    # ./hardware.nix
    # ./sops.nix
    # ./network.nix

    # ./networking.nix
    # ./remaining.nix
    # ./rockchip.nix
  ];

  # boot.loader.grub.enable = false;

  system.image.version = "1";

  nixpkgs.buildPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  environment.systemPackages = [
    pkgs.parted
  ];

  system.stateVersion = "26.05";
}
