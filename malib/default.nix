{ lib
, config
, ...
}:

{
  options.malib = lib.mkOption {
    type = with lib.types; functionTo (attrsOf (functionTo unspecified));
    default = pkgs:
      (lib.mergeAttrsList
        (builtins.map (x: import x { inherit lib config pkgs; }) [
          ./constructor.nix
          ./utils.nix
        ])
      );
  };
}
