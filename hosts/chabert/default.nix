{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.chabert

    ./configuration.nix
    ./disko-config.nix

    ./sops.nix
    ./network.nix

    # ./services

    ../share/cloud
    ./minecraft-server
  ];

  nix.channel.enable = false;
}
