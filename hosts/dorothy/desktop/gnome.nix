let
  enable = false;
in
{
  services.xserver.desktopManager.gnome = {
    inherit enable;
  };
}
