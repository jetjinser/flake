{
  flake,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
in
mkHM (
  { pkgs, ... }:
  {
    home.packages = [ pkgs.waylyrics ];
  }
)
// {
}
