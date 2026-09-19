{
  inputs,
  lib,
  ...
}:

let
  # NOTE: use `prev` instead of `final`: nixpkgs applies user overlays
  # during every stdenv bootstrap stage, and forcing `final.lib` there
  # recurses into the incomplete fixpoint.
  pkgsOverlay =
    _final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (prev) callPackage;
      directory = ../pkgs;
    };

  pypkgsOverlay = _final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (
        pyFinal: pyPrev:
        pyPrev.lib.packagesFromDirectoryRecursive {
          inherit (pyFinal) callPackage;
          directory = ../pypkgs;
        }
      )
    ];
  };
in

{
  flake.overlays.default = lib.composeManyExtensions [
    pkgsOverlay
    pypkgsOverlay
  ];

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.deploy-rs.overlays.default
          pkgsOverlay
          pypkgsOverlay
        ];
      };

      packages.deploy-rs = pkgs.deploy-rs.deploy-rs;
    };
}
