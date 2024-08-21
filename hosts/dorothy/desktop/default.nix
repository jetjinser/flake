{ pkgs
, ...
}:

{
  imports = [
    ./login.nix
    # ./gnome.nix
    ./niri.nix
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    xdgOpenUsePortal = true;
  };

  services = {
    upower.enable = true;
    pipewire.enable = true;
  };

  hardware.pulseaudio = {
    enable = true;
    support32Bit = true;
  };
}
