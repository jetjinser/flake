{ pkgs
, lib
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
      # spawn-at-startup = [ ];
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
    libnotify

    wl-clipboard

    brightnessctl
    # wluma

    grim
    slurp
    swayimg
    swaybg

    # wayland-utils
  ];

  systemd.user.services = {
    "swaybg" = {
      Unit = {
        Description = "showing wallpaper";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };
      Service =
        let
          show = pkgs.writeShellApplication {
            name = "show-wallpaper";
            runtimeInputs = [ pkgs.swaybg ];

            text = ''
              wallpaper=$(find ${../../../assets/wallpaper} -maxdepth 1 | shuf -n 1)
              swaybg -i "$wallpaper"
            '';
          };
        in
        {
          ExecStart = lib.getExe' show "show-wallpaper";
          Restart = "on-failure";
        };
      Install.WantedBy = [ "graphical-session.target" ];
    };
    # https://github.com/maximbaz/wluma/blob/8df0b8e2c04c9e7bf0a5f560d59e29786cc5be8e/wluma.service
    # "wluma" = {
    #   Unit = {
    #     Description = "Adjusting screen brightness based on screen contents and amount of ambient light";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #     Requisite = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     ExecStart = lib.getExe' pkgs.wluma "wluma";
    #     Restart = "always";
    #     EnvironmentFile = "-%E/wluma/service.conf";
    #     PrivateNetwork = true;
    #     PrivateMounts = false;
    #   };
    #   Install.WantedBy = [ "graphical-session.target" ];
    # };
  };

  services.mako = {
    enable = true;
    layer = "top";
    anchor = "top-right";
    backgroundColor = "#686688ee";
    borderColor = "#4C7899FF";
    borderRadius = 2;
    borderSize = 3;
    defaultTimeout = 7000;
    font = "monospace 13";
    height = 300;
    width = 500;
    margin = "10";
    padding = "5";

    extraConfig = ''
      [urgency=low]
      border-color=#8be9fd

      [urgency=normal]
      border-color=#bd93f9

      [urgency=high]
      border-color=#ff5555
      default-timeout=0
    '';
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
    enable = false;
    systemd.enable = true;
    settings.mainBar.layer = "top";
  };
}
