{ lib
, pkgs
, ...
}:

{
  imports = [
    ../../../modules/servicy/betula.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      betula = prev.betula.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/NixOS/nixpkgs/pull/284785/commits/467fd5bd7d977078eac2c76ea2a24c1706623542.patch";
            hash = lib.fakeHash;
          })
        ];
      });
    })
  ];

  servicy.betula = {
    enable = true;
    package = pkgs.betula;
    openFirewall = true;
  };
}
