{
  pkgs,
  ...
}:

let
  enable = true;
in
{
  services.desktopManager.gnome = {
    inherit enable;
  };
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
  ];
}
