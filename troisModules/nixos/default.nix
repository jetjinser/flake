{
  self,
  inputs,
  config,
  ...
}:

let
  inherit (config.symbols) people;

  inherit (config.lib) mkHMs;
in
{
  # Configuration common to all Linux systems
  flake = {
    nixosModules = {
      # Configuration common to all Linux systems.
      common.imports = [
        ./config.nix
        ./nix.nix
        ./prelude.nix
        ./uncat.nix
        # NOTE: nix-topology ships only a nixos module
        # (_class = "nixos"); it must stay in this nixos-only
        # attr, not in the shared prelude.nix which darwin
        # imports as raw files.
        inputs.nix-topology.nixosModules.default
        # NOTE: nix-darwin has no programs.command-not-found.
        { programs.command-not-found.enable = false; }
        # NOTE: nix-darwin has no security.sudo-rs.
        {
          security.sudo-rs = {
            enable = true;
            execWheelOnly = true;
            wheelNeedsPassword = true;
          };
        }
        # NOTE: system.extraDependencies is provided by nixos-flake's
        # nixos module; nix-darwin has no such option.
        # https://github.com/oxalica/nixos-config/blob/706adc07354eb4a1a50408739c0f24a709c9fe20/nixos/modules/nix-keep-flake-inputs.nix
        (
          { flake, ... }:
          {
            system.extraDependencies =
              let
                collectFlakeInputs =
                  input:
                  [ input ] ++ builtins.concatMap collectFlakeInputs (builtins.attrValues (input.inputs or { }));
              in
              builtins.concatMap collectFlakeInputs (builtins.attrValues flake.inputs);
          }
        )
      ];

      chezmoi = {
        users.users.${people.myself} = {
          isNormalUser = true;
          uid = 1000;
        };
        users.groups.users.gid = 100;
        imports = [
          ./HMSharedModules.nix
        ];
      }
      // (mkHMs [
        self.homeModules.common-linux
      ]);

      default.imports = [
        self.nixosModules.home-manager
        self.nixosModules.chezmoi

        self.nixosModules.common
      ];

      # =======

      bendemann.imports = [
        self.nixosModules.default
        (mkHMs [
          # ../home/default.nix
          self.homeModules.bendemann
        ])
      ];

      dorothy.imports = [
        self.nixosModules.default
        (mkHMs [
          # ../home/default.nix
          self.homeModules.dorothy
        ])
      ];

      chabert.imports = [
        self.nixosModules.default
      ];

      sheep.imports = [
        self.nixosModules.default
      ];

      karenina.imports = [
        self.nixosModules.default
      ];
    };
  };
}
