{
  lib,
  ...
}:

with lib;
let
  userSubmodule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
      };
      email = mkOption {
        type = types.str;
      };
      sshKeys = mkOption {
        type = types.listOf types.str;
        description = ''
          SSH public keys
        '';
      };
    };
  };
  peopleSubmodule = types.submodule {
    options = {
      users = mkOption {
        type = types.attrsOf userSubmodule;
      };
      myself = mkOption {
        type = types.str;
        description = ''
          The name of the user that represents myself.

          Admin user in all contexts.
        '';
      };
    };
  };
in
{
  options.symbols = {
    people = mkOption {
      type = peopleSubmodule;
    };
  };
  config.symbols = {
    people = import ./config.nix;
  };
}
