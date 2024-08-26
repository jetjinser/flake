{
  imports = [
    ./login.nix
    # ./gnome.nix
    ./niri.nix
  ];

  services = {
    upower.enable = true;
    pipewire.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
}
