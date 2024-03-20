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
  flake = {
    darwinModules = {
      chezmoi = mkHM' [
        self.homeModules.common-darwin
      ];

      default.imports = [
        # from nixos-flake
        self.darwinModules_.home-manager
        self.darwinModules.chezmoi

        # shared bettwen NixOS and nix-darwin
        # ../nixos/default.nix
        self.nixosModules.common
      ];

      # =======

      julien.imports = [
        self.darwinModules.default
        (mkHM' [
          # ../home/default.nix
          self.homeModules.julien
        ])
      ];
    };
  };
}

