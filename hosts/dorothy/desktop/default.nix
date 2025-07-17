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

  services = {
    upower.enable = true;
    pipewire.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = [ pkgs.vaapiVdpau ];
  };
}
