{ pkgs
, ...
}:

{
  services.xserver = {
    enable = true;
    excludePackages = [
      pkgs.xterm
    ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  # config gdm face workaround
  # https://discourse.nixos.org/t/setting-the-user-profile-image-under-gnome/36233/5
  # https://help.gnome.org/admin/gdm/stable/overview.html.en#facebrowser
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${../../../assets/face.jpg} /var/lib/AccountsService/icons/jinser
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/jinser\n" > /var/lib/AccountsService/users/jinser
  '';


  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
