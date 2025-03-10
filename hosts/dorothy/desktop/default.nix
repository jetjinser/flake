{
  imports = [
    ./login.nix
    ./niri.nix
  ];

  xdg.portal.xdgOpenUsePortal = true;

  services = {
    upower.enable = true;
    pipewire.enable = true;
  };

  services.sunshine = {
    enable = false;
    openFirewall = true;
    capSysAdmin = true;
  };
}
