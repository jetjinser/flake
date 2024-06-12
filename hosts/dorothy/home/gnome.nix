{ pkgs
, ...
}:

{
  home.packages = with pkgs.gnomeExtensions; [
    kimpanel
  ];

  dconf = {
    enable = true;
    settings."org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        kimpanel.extensionUuid
      ];
    };
  };
}
