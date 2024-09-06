{ pkgs
, ...
}:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        # fcitx5-rime
        fcitx5-chinese-addons

        fcitx5-gtk
        libsForQt5.fcitx5-qt
      ];
    };
  };
}
