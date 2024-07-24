{ pkgs
, config
, ...
}:

{
  programs.niri = {
    settings = {
      hotkey-overlay.skip-at-startup = true;
      input = {
        warp-mouse-to-focus = true; # dunno meaning
        workspace-auto-back-and-forth = true;
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          click-method = "clickfinger";
        };
        keyboard = {
          repeat-delay = 300;
        };
      };
      spawn-at-startup = [
        { command = [ "foot" "--server" ]; }
        # TODO: niri does not support input-method-v1 or v3 yet
        # { command = [ "fcitx5" "-d" "--replace" ]; }
        { command = [ "swaybg" "-m" "center" "-i" "${../../../assets/116567097_p0.jpg}" ]; }
      ];
      binds = with config.lib.niri.actions; let
        sh = spawn "sh" "-c";

        screenshot-area-script = pkgs.writeShellScript "screenshot-area" ''
          grim -g "$(slurp)" - | wl-copy -t image/png
        '';
        screenshot-area = spawn "${screenshot-area-script}";
      in
      {
        "Mod+Return".action = spawn "footclient";
        "Mod+Space".action = spawn "fuzzel";

        "Mod+BackSpace".action = close-window;

        "Print".action = screenshot-area;
        "Mod+Print".action = screenshot-window;

        "Mod+Shift+Q".action = quit;
        "Mod+Shift+P".action = power-off-monitors;
        "Mod+Shift+Ctrl+T".action = toggle-debug-tint;

        "Mod+R".action = switch-preset-column-width;
        "Mod+F".action = fullscreen-window;
        "Mod+C".action = center-column;

        "Mod+M".action = maximize-column;
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        "Mod+Alt+Minus".action = set-window-height "-10%";
        "Mod+Alt+Equal".action = set-window-height "+10%";

        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-workspace-down;
        "Mod+K".action = focus-workspace-up;
        "Mod+L".action = focus-column-right;

        "XF86AudioRaiseVolume".action = sh "pactl set-sink-volume @DEFAULT_SINK@ +10%";
        "XF86AudioLowerVolume".action = sh "pactl set-sink-volume @DEFAULT_SINK@ -10%";
        "XF86AudioMute".action = sh "pactl set-sink-mute @DEFAULT_SINK@ toggle";

        "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
        "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";
      };
      window-rules = [
        {
          matches = [{ app-id = "^foot(?:client)?$"; }];
          default-column-width = { proportion = 0.5; };
        }
      ];
    };
  };

  home.packages = with pkgs; [
    # libnotify
    wl-clipboard
    # wayland-utils
    brightnessctl
    grim
    slurp
    swayimg
    swaybg
  ];

  systemd.user.services."swaybg" = {
    Unit = {
      Description = "showing wallpapers";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${../../../assets/116567097_p0.jpg}";
      Restart = "on-failure";
    };
  };

  services.mako = {
    enable = true;
    borderRadius = 8;
    format = "%a\n%s\n%b";
  };

  programs.foot = {
    enable = true;
    server.enable = true;
    settings = import ./components/foot.nix;
  };
  programs.fuzzel = {
    enable = true;
    settings.main.terminal = "foot";
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings.mainBar.layer = "top";
  };
}
