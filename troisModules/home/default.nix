{
  self,
  inputs,
  ...
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

      dev = {
        imports = [ ../home/dev.nix ];
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
        self.homeModules.common
        ../../hosts/bendemann/home
        ./dev.nix
      ];

      dorothy.imports = [
        self.homeModules.common
        ../../hosts/dorothy/home
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
