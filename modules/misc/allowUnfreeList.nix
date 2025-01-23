{ lib
, config
, ...
}:


let
  cfg = config.nixpkgs.superConfig;
in
{
  options.nixpkgs.superConfig = {
    allowUnfreeList =
      lib.mkOption {
        type = with lib.types; listOf str;
        default = [ ];
        description = "List of package name allow unfree.";
      };
  };

  config = lib.mkIf (cfg.allowUnfreeList != [ ]) {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) cfg.allowUnfreeList;
  };
}
