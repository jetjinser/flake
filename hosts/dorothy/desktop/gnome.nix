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
    # keep-sorted start
    cheese # webcam tool
    epiphany # web browser
    evince # document viewer
    geary # email reader
    gedit # text editor
    gnome-tour
    totem # video player
    # keep-sorted end
  ]) ++ (with pkgs.gnome; [
    # keep-sorted start
    atomix # puzzle game
    gnome-characters
    hitori # sudoku game
    iagno # go game
    tali # poker game
    # keep-sorted end
  ]);

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
            hash = "sha256-nz1Enw1NjxLEF3JUG0qknJgf4328W/VvdMjJmoOEMYs=";
          };
        });
      });
    })
  ];
}
