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
          ./share
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
          # TODO: think a good new name
          ./darwin
        ];
      };

      # =======

      julien.imports = [
        ../../hosts/julien/home
        ./share/dev.nix
      ];

      # ===

      chabert.imports = [
        ../../hosts/chabert/home
        ./share/dev.nix
      ];

      cosimo.imports = [
        ../../hosts/chabert/home
        ./share/dev.nix
      ];

      # ===

      barnabas.imports = [
        ../../hosts/barnabas/home
      ];

      karenina.imports = [
        ../../hosts/karenina/home
        ./share/dev.nix
      ];
    };
  };
}

