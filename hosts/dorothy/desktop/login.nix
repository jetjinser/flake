{ pkgs
, flake
, ...
}:

let
  inherit (flake.inputs) nixpkgs-uwsm;
in
{
  imports = [
    # "${nixpkgs-uwsm}/nixos/modules/services/misc/graphical-desktop.nix"
    "${nixpkgs-uwsm}/nixos/modules/programs/wayland/uwsm.nix"
  ];

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

  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri";
      };
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
