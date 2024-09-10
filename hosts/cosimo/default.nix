{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.cosimo
    flake.inputs.sops-nix.nixosModules.sops

    ./configuration.nix
    ./disko-config.nix

    ./sops.nix
    ./services
    ./network.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
