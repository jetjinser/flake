{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    ...
  }:

  let
    flakeRoot = ../../../.;
    base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));
  in
  {
    home.packages = [ base ];
  }
)
// {
  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ ".radicle" ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${myself}/vie/projet/flake";
  };
  nix.gc.automatic = false;
}
