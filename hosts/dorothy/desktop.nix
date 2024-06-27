{ pkgs
, ...
}:

{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  services.libinput.touchpad = {
    disableWhileTyping = true;
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
    gedit # text editor
  ]) ++ (with pkgs.gnome; [
    cheese # webcam tool
    epiphany # web browser
    geary # email reader
    evince # document viewer
    gnome-characters
    totem # video player
    tali # poker game
    iagno # go game
    hitori # sudoku game
    atomix # puzzle game
  ]);

  # config gnome face workaround
  # https://discourse.nixos.org/t/setting-the-user-profile-image-under-gnome/36233/5
  # https://help.gnome.org/admin/gdm/stable/overview.html.en#facebrowser
  system.activationScripts.script.text = ''
    mkdir -p /var/lib/AccountsService/{icons,users}
    cp ${../../assets/face.jpg} /var/lib/AccountsService/icons/jinser
    echo -e "[User]\nIcon=/var/lib/AccountsService/icons/jinser\n" > /var/lib/AccountsService/users/jinser
  '';

  nixpkgs.overlays = [
    # https://wiki.nixos.org/wiki/GNOME#Dynamic_triple_buffering
    # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1441
    # GNOME 46: triple-buffering-v4-46
    (_final: prev: {
      gnome = prev.gnome.overrideScope (_gnomeFinal: gnomePrev: {
        mutter = gnomePrev.mutter.overrideAttrs (_old: {
          src = pkgs.fetchFromGitLab {
            domain = "gitlab.gnome.org";
            owner = "vanvugt";
            repo = "mutter";
            rev = "triple-buffering-v4-46";
            hash = "sha256-fkPjB/5DPBX06t7yj0Rb3UEuu5b9mu3aS+jhH18+lpI=";
          };
        });
      });
    })
  ];
}
