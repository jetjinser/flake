{ flake
, pkgs
, config
, lib
, ...
}:
{
  imports = [
    flake.inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = with config.lib.niri.actions; {
      input.touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = true;
        click-method = "clickfinger";
      };
      spawn-at-startup = [
        { command = [ "foot --server" ]; }
      ];
      binds = {
        "Mod+T".action = spawn "footclient";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libnotify
    wl-clipboard
    wayland-utils
  ];

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = import ../components/foot.nix { inherit pkgs lib; };
  };
  programs.fuzzel = {
    enable = true;
    settings.main.terminal = "foot";
  };
}
