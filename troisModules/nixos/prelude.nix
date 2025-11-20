{
  pkgs,
  lib,
  flake,
  ...
}:

{
  imports = [
    flake.inputs.nix-topology.nixosModules.default
  ];

  environment.systemPackages = map lib.lowPrio (
    with pkgs;
    [
      # keep-sorted start
      curl
      file
      git
      jq
      screen
      zuo # maybe Guile?
      # keep-sorted end
    ]
  );

  nixpkgs.overlays = [
    (
      final: prev:
      prev.lib.packagesFromDirectoryRecursive {
        inherit (prev) callPackage;
        directory = ../../modules/pkgs;
      }
    )
  ];
}
