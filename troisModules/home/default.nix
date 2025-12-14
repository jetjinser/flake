{
  self,
  inputs,
  lib,
  ...
}:

{
  flake = {
    homeModules = {
      common = {
        home.stateVersion = "24.05";
        programs.home-manager.enable = true;
        manual.manpages.enable = lib.mkDefault false;
        imports = [
          inputs.nix-index-database.homeModules.nix-index
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
