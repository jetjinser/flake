{ self
, config
, ...
}:

let
  inherit (config.malib) mkHMs;
in
{
  flake = {
    darwinModules = {
      chezmoi = mkHMs [
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
        (mkHMs [
          # ../home/default.nix
          self.homeModules.julien
        ])
      ];
    };
  };
}

