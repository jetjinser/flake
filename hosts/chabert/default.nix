{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.chabert

    ./configuration.nix
    ./disko-config.nix
    ./network.nix

    ./sops.nix
    # ./services
    # ./minecraft-server

    ../share/cloud
  ];

  nix.channel.enable = false;
}
