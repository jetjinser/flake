{ self
, inputs
, ...
}:

{
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
        imports = [
          inputs.nix-index-database.hmModules.nix-index
          # TODO: spilt it into server/desktop/...
          ./git.nix
          ./shell
        ];
      };

      common-linux = {
        imports = [
          self.homeModules.common
        ];
      };

      common-darwin = {
        imports = [
          self.homeModules.common
        ];
      };

      # =======

      julien.imports = [
        ../../hosts/julien/home
        ./dev.nix
      ];

      # ===

      bendemann.imports = [
        ../../hosts/bendemann/home
        ./dev.nix
      ];

      dorothy.imports = [
        ../../hosts/dorothy/home
        ./dev.nix
      ];

      chabert.imports = [
        ../../hosts/chabert/home
        ./dev.nix
      ];

      cosimo.imports = [
        ../../hosts/chabert/home
        ./dev.nix
      ];

      sheep.imports = [
        ../../hosts/sheep/home
        ./dev.nix
      ];

      # ===

      karenina.imports = [
        ../../hosts/karenina/home
        ./dev.nix
      ];
    };
  };
}

