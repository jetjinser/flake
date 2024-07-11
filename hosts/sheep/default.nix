{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.sheep

    ./configuration.nix
    ./disko-config.nix
    ./network.nix

    ./dev.nix
    ./sops.nix
    ./services

    ../share/cloud
  ];

  nix.channel.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
