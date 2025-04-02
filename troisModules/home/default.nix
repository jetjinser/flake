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

      dev.imports = [
        ./dev.nix
        ./shell/starship.nix
      ];

      common-linux.imports = [ self.homeModules.common ];
      common-darwin.imports = [ self.homeModules.common ];

      # =======

      julien.imports = [
        self.homeModules.dev
        ../../hosts/julien/home
      ];

      # ===

      bendemann.imports = [
        self.homeModules.dev
        ../../hosts/bendemann/home
      ];

      dorothy.imports = [
        self.homeModules.dev
        ../../hosts/dorothy/home
      ];
    };
  };
}
