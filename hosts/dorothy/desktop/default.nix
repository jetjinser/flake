{
  imports = [
    ./login.nix
    # ./gnome.nix
    ./niri.nix
  ];

  xdg.portal.xdgOpenUsePortal = true;

  services = {
    upower.enable = true;
    pipewire.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
}
