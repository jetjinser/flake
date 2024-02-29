{ inputs
, ...
}:

let
  mkAlist = pkgs: pkgs.callPackage ../modules/pkgs/alist.nix { };
in
{
  perSystem = { system, ... }: {
    _module.args.qkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        (final: _prev: {
          alist = mkAlist final;
        })
      ];
    };

    # packages = rec {
    #   default = alist;
    #   alist = mkAlist pkgs;
    # };
  };
}
