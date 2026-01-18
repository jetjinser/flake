{
  flake,
  pkgs,
  ...
}:

{
  imports = [ flake.config.modules.nixos.misc ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # fcitx5-gtk
        kdePackages.fcitx5-qt
        qt6Packages.fcitx5-chinese-addons
        # theme
        fcitx5-fluent
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            "DefaultIM" = "pinyin";
          };
          "Groups/0/Items/0" = {
            Name = "keyboard-us";
          };
          "Groups/0/Items/1" = {
            Name = "pinyin";
          };
          GroupOrder."0" = "Default";
        };
        addons.classicui.globalSection = {
          Theme = "FluentLight-solid";
          DarkTheme = "FluentDark-solid";
          UseDarkTheme = true;
          EnableFractionalScale = true;
        };
      };
    };
  };
}
