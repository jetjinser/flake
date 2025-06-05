let
  enable = false;
in
{
  services.desktopManager.gnome = {
    inherit enable;
  };
}
