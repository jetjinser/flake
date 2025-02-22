{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      cmus
    ];
  }
)
// {
}
