{ pkgs
, flake
, ...
}:

{
  services.xserver = {
    enable = true;
    excludePackages = [
      pkgs.xterm
    ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
