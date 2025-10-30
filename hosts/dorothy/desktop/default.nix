{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake.config.lib) importx;
in
{
  imports = importx ./. { };

  xdg.portal.xdgOpenUsePortal = true;

  security.rtkit.enable = true;
  services = {
    upower.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.libva-vdpau-driver ];
  };
}
