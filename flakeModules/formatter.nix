{ inputs
, lib
, ...
}:

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
        projectRootFile = ../flake.nix;
        package = pkgs.treefmt;

        programs = {
          keep-sorted.enable = true;

          # nix
          nixpkgs-fmt.enable = true;
          deadnix.enable = true;
          statix.enable = true;

          # lua
          stylua.enable = true;

          # shell
          shfmt.enable = true;

          # python
          black.enable = true;
        };

        settings.formatter = {
          keep-sorted = {
            includes = lib.mkForce [ "*.nix" ];
          };
        };
      };
    };
}
