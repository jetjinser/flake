{
  self,
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
      # NixOS modules that are known to work on nix-darwin.
      common.imports = [
        ./config.nix
        ./nix.nix
        ./prelude.nix
      ];

      chezmoi =
        {
          users.users.${people.myself}.isNormalUser = true;
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

      cosimo.imports = [
        self.nixosModules.default
      ];

      sheep.imports = [
        self.nixosModules.default
      ];
      sheepro.imports = [
        self.nixosModules.default
      ];

      barnabas.imports = [
        self.nixosModules.common
      ];

      karenina.imports = [
        self.nixosModules.default
      ];
    };
  };
}
