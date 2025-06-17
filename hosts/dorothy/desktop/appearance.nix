{
  flake,
  lib,
  config,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
in
mkHM (
  { pkgs, ... }:
  {
    gtk = {
      enable = false;
      cursorTheme.name = "BreezeX-RoséPine";
      cursorTheme.package = pkgs.rose-pine-cursor;
      iconTheme.name = "Colloid-Light";
      iconTheme.package = pkgs.colloid-icon-theme;
      theme.name = "Colloid";
      theme.package = pkgs.colloid-gtk-theme;
    };
    qt = {
      enable = false;
      platformTheme.name = "gtk";
    };
  }
)
// {
}
