# INFO: WIP

{ lib
, ...
}:

with lib;
let
  systemSubmodule = types.submodule {
    options = {
      allDarwin = mkOption {
        type = with types; listOf package;
      };
      allNixOS = mkOption {
        type = with types; listOf package;
      };
      allNodes = mkOption {
        # let deploy-rs check it
        type = with types; lazyAttrsOf unspecified;
      };
    };
  };
in
{
  options.systems = {
    systems = mkOption {
      type = systemSubmodule;
    };
  };
  config.systems = {
    systems = import ./config.nix;
  };
}

