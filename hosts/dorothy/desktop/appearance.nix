{
  flake,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
in
mkHM (
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      colloid-icon-theme
      rose-pine-cursor
    ];

    gtk = {
      enable = true;
      cursorTheme.name = "BreezeX-RoséPine";
      cursorTheme.package = pkgs.rose-pine-cursor;
      iconTheme.name = "Colloid-Light";
      iconTheme.package = pkgs.colloid-icon-theme;
      theme.name = "Colloid";
      theme.package = pkgs.colloid-gtk-theme;
    };
    qt = {
      enable = true;
      platformTheme.name = "gtk";
    };
  }
)
// {
}
