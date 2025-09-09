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
    # keep-sorted start
    atomix
    baobab
    cheese
    epiphany
    evince
    file-roller
    geary
    gnome-backgrounds
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-connections
    gnome-contacts
    gnome-disk-utility
    gnome-extension-manager
    gnome-logs
    gnome-maps
    gnome-music
    gnome-photos
    gnome-software
    gnome-system-monitor
    gnome-text-editor
    gnome-themes-extra
    gnome-tour
    gnome-user-docs
    gnome-weather
    hitori
    iagno
    localsearch
    loupe
    nautilus
    orca
    seahorse
    simple-scan
    snapshot
    sushi
    tali
    totem
    yelp
    # keep-sorted end
  ];
}
