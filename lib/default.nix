{ lib
, config
, ...
}:

{
  options.lib = lib.mkOption {
    type = with lib.types; attrsOf (functionTo unspecified);
    default = (lib.mergeAttrsList
      (builtins.map (x: import x { inherit lib config; }) [
        ./constructor.nix
        ./importx.nix
      ])
    );
  };
}
