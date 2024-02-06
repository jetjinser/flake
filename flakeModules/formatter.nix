{ inputs, ... }:

{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  perSystem =
    { config
    , pkgs
    , ...
    }: {

      treefmt.config = {
        inherit (config.flake-root) projectRootFile;
        package = pkgs.treefmt;

        programs = {
          nixpkgs-fmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;
        };
      };
    };
}
