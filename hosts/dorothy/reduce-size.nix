{
  lib,
  config,
  ...
}:

let
  cfg = config.reduction.size;

  mkEnableTrue =
    doc:
    lib.mkEnableOption doc
    // {
      default = true;
    };
in
{
  options.reduction.size = {
    enable = mkEnableTrue "";
  };

  config = lib.mkIf cfg.enable {
    services.speechd.enable = false;

    nixpkgs.overlays = lib.mkMerge [
      (lib.mkIf false [
        (final: prev: {
        })
      ])
    ];
  };
}
