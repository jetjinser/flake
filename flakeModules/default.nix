{ inputs, ... }:

{
  imports = [
    ./devshell
    ./formatter.nix
    ./overlays.nix
    ./hook.nix
    ./topology.nix
  ];

  perSystem =
    {
      system,
      pkgs,
      self',
      lib,
      ...
    }:
    {
      packages = lib.filterAttrs (_: lib.isDerivation) (
        (lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ../pkgs;
        })
        // (lib.packagesFromDirectoryRecursive {
          inherit (pkgs.python3Packages) callPackage;
          directory = ../pypkgs;
        })
      );

      apps = { };
    };
}
