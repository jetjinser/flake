{ self
, config
, pkgs
, ...
}:

let
  inherit (config.symbols) people;

  inherit (config.malib pkgs) mkHM;
  mkHM' = mkHM people.myself;
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

      chezmoi = {
        users.users.${people.myself}.isNormalUser = true;
      } // (mkHM' [
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
        (mkHM' [
          # ../home/default.nix
          self.homeModules.bendemann
        ])
      ];

      chabert.imports = [
        self.nixosModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.chabert
        ])
      ];

      cosimo.imports = [
        self.nixosModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.cosimo
        ])
      ];

      sheep.imports = [
        self.nixosModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.sheep
        ])
      ];

      barnabas.imports = [
        self.nixosModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.barnabas
        ])
      ];

      karenina.imports = [
        self.nixosModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.karenina
        ])
      ];
    };
  };
}

