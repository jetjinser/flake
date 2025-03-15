{
  flake,
  ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.sheepro

    ./configuration.nix
    ./sops.nix
    ./services

    ../share/cloud
  ];

  nix.channel.enable = false;
}
