{
  inputs,
  ...
}:

let
  mkAlist = pkgs: pkgs.callPackage ../modules/pkgs/alist.nix { };
  mkUbootNanopiR2s = pkgs: pkgs.callPackage ../modules/pkgs/uboot-nanopi-r2s { };
in
{
  perSystem =
    { system, ... }:
    {
      _module.args.qkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          (final: _prev: {
            alist = mkAlist final;
            ubootNanopiR2s = mkUbootNanopiR2s final;
          })
        ];
      };
    };
}
