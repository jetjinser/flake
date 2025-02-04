{ flake
, ...
}:

{
  imports = [
    flake.self.nixosModules.barnabas

    ./configuration.nix
    ./hardware.nix
    ./sops.nix
    ./network.nix
    ../share/cloud

    ./networking.nix
    ./remaining.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  nix.channel.enable = false;

  topology.self = {
    hardware.info = "NanoPi R2S";
  };
}
