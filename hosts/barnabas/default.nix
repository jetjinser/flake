{ flake
, ...
}:

{
  imports = [
    flake.self.nixosModules.barnabas

    ./configuration.nix
    ./hardware.nix
    ./networking.nix

    ./sops.nix
    ./network.nix
    ./remaining.nix

    ../share/cloud
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  nix.channel.enable = false;
}
