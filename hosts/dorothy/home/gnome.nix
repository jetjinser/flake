{ pkgs
, ...
}:

{
  home.packages = with pkgs.gnomeExtensions; [
    kimpanel
    pop-shell
  ];

  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        kimpanel.extensionUuid
        pop-shell.extensionUuid
      ];
    };
  };
}
