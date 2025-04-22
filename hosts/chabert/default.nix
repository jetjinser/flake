{
  flake,
  ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.chabert

    ./configuration.nix
    ./disko-config.nix
    ./network.nix

    ./persist.nix
    ./sops.nix
    ./services

    ../share/cloud
  ];

  nix.channel.enable = false;
}
