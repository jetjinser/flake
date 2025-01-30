{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.cosimo

    ./configuration.nix
    ./disko-config.nix

    ./sops.nix
    ./services
    ./network.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
