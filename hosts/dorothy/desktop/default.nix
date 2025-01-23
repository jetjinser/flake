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
}
