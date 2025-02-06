{
  pkgs,
  flake,
  ...
}:

{
  imports = [
    flake.inputs.hyprland.homeManagerModules.default
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = "";
  };

  xdg = {
    configFile = {
      "rofi" = {
        recursive = true;
        source = ../../../config/rofi;
      };
      "hypr" = {
        recursive = true;
        source = ../../../config/hypr;
      };
    };
  };

  programs = {
    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
    };
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.rose-pine-gtk-theme;
      name = "Rosé Pine Moon";
    };
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 22;
    };
  };

  home.packages = with pkgs; [
    at-spi2-core

    mpv
    imv

    swaybg

    wl-clipboard
    wlogout
    wf-recorder

    dconf

    slurp
    grim

    mako
    libnotify

    wlsunset
  ];
}
