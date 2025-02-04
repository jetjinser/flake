{ inputs
, config
, ...
}:

{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem = { ... }: {
    topology.modules = [
      {
        nixosConfigurations = config.flake.nixosConfigurations;
      }
    ];
  };
}
