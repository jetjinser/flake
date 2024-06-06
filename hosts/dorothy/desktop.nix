{
  services.xserver = {
    enable = true;
    displayManager = {
      gdm.enable = true;
      gnome.enable = true;
    };
  };
}
