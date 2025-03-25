{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
  inherit (flake.config.symbols.people) myself;
in
mkHM (
  {
    pkgs,
    lib,
    config,
    flake,
    ...
  }:

  {
    imports = [
      flake.config.modules.home.programs
      flake.inputs.niri.homeModules.config
    ];

    programs.niri = {
      package = pkgs.niri;
      settings =
        let
          wpctl = lib.getExe' pkgs.wireplumber "wpctl";
        in
        {
          prefer-no-csd = true;
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
            {
              command = [
                (lib.getExe' pkgs.radicle-node "rad")
                "node"
                "start"
              ];
            }
            {
              # set mute default
              command = [
                wpctl
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "1"
              ];
            }
          ];
          binds =
            with config.lib.niri.actions;
            let
              sh = spawn "sh" "-c";
            in
            {
              "Mod+Return".action = spawn "footclient";
              "Mod+Space".action = spawn "fuzzel";

              "Mod+BackSpace".action = close-window;

              "Print".action = screenshot;
              "Mod+Print".action = screenshot-window;
              # https://github.com/sodiboo/niri-flake/issues/922
              "Mod+Ctrl+Print".action.screenshot-screen = [ ];

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

              "XF86AudioRaiseVolume".action = sh "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 10%+";
              "XF86AudioLowerVolume".action = sh "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 10%-";
              "XF86AudioMute" = {
                repeat = false;
                cooldown-ms = 500;
                action = spawn (
                  lib.getExe' (pkgs.writeShellApplication {
                    name = "toggle-mute";
                    runtimeInputs = with pkgs; [
                      wireplumber
                      brightnessctl
                      gnugrep
                      libnotify
                    ];
                    text = ''
                      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
                      volume_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)

                      # FIXME: cannot works brightnessctl
                      if echo "$volume_info" | grep -q "MUTED"; then
                          # brightnessctl -d 'platform::fnlock' set 0
                          notify-send 'Muted: Yes'
                      else
                          # brightnessctl -d 'platform::fnlock' set 1
                          notify-send 'Muted: No'
                      fi
                    '';
                  }) "toggle-mute"
                );
              };
              "XF86MonBrightnessUp".action = sh "brightnessctl set 10%+";
              "XF86MonBrightnessDown".action = sh "brightnessctl set 10%-";
            };
          window-rules = [
            {
              matches = [ { app-id = "^foot(?:client)?$"; } ];
              default-column-width = {
                proportion = 0.5;
              };
            }
            {
              matches = [
                { app-id = "^foot(?:client)?$"; }
                { is-focused = true; }
              ];
              draw-border-with-background = true;
            }
          ];
        };
    };

    home.packages = with pkgs; [
      libnotify

      wl-clipboard

      brightnessctl
      pulseaudio
      # wluma

      grim
      slurp
      imv
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
                wallpaper=$(find ${../../../assets/wallpaper} -maxdepth 1 -type f | shuf -n 1)
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
      settings = import ../components/foot.nix;
    };
    programs.fuzzel = {
      enable = true;
      settings.main = {
        terminal = "foot";
        prompt = "λ. ";
        show-actions = true;
      };
      # https://github.com/folke/tokyonight.nvim/blob/057ef5d260c1931f1dffd0f052c685dcd14100a3/extras/fuzzel/tokyonight_moon.ini
      settings.colors = {
        background = "1e2030ff";
        text = "c8d3f5ff";
        match = "65bcffff";
        selection = "363c58ff";
        selection-match = "65bcffff";
        selection-text = "c8d3f5ff";
        border = "589ed7ff";
      };
    };
  }
)
// {
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ "Pictures" ];
  };
}
