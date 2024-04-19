{ pkgs
, ...
}:

{
  imports = [
    ../../../modules/servicy/betula.nix
  ];

  servicy.betula = {
    enable = true;
    package = pkgs.callPackage ../../../packages/betula.nix { };
  };
}
