{ lib
, flake-parts-lib
, ...
}:

let
  inherit (lib)
    mkOption
    types
    ;
  inherit (flake-parts-lib)
    mkTransposedPerSystemModule
    ;
in
mkTransposedPerSystemModule {
  name = "typhonJobs";
  option = mkOption {
    type = types.lazyAttrsOf types.package;
    default = { };
    description = ''
      An attribute set of packages to be built by [typhon](https://github.com/typhon-ci/typhon).
    '';
  };
  file = ./typhon.nix;
}
