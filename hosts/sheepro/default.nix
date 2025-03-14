{
  flake,
  ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.sheepro

    ./configuration.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
