{ lib
, ...
}:

with lib;
let
  machineSubmodule = types.submodule
    {
      options = {
        host = mkOption {
          type = types.str;
        };
        port = mkOption {
          type = types.port;
          default = 22;
        };
      };
    };
in
{
  options.symbols = {
    machines = mkOption {
      type = types.attrsOf machineSubmodule;
    };
  };

  config.symbols = {
    machines = import ./config.nix;
  };
}
