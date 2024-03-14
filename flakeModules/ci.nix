let
  mkAlist = pkgs: pkgs.callPackage ../modules/pkgs/alist.nix { };
  mkUbootNanopiR2s = pkgs: pkgs.callPackage ../modules/pkgs/uboot-nanopi-r2s { };
in
{
  perSystem = { pkgs, ... }: {
    typhonJobs = {
      alist = mkAlist pkgs;
      ubootNanopiR2s = mkUbootNanopiR2s pkgs;
    };
  };
}
