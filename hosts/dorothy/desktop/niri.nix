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

  let
    niri-settings = config.programs.niri.settings;
  in
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
            warp-mouse-to-focus.enable = true; # dunno meaning
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
              # set mute default
              command = [
                wpctl
                "set-mute"
                "@DEFAULT_AUDIO_SINK@"
                "1"
              ];
            }
          ];
          xwayland-satellite = {
            enable = true;
            path = lib.getExe pkgs.xwayland-satellite;
          };
          outputs = {
            "eDP-1" = {
              mode = {
                width = 2880;
                height = 1800;
                refresh = 120.003;
              };
              scale = 1.75;
              position = {
                x = 0;
                y = 0;
              };
              focus-at-startup = true;
            };
            "HDMI-A-1" = {
              mode = {
                width = 3840;
                height = 2160;
                refresh = 60.000;
              };
              scale = 1.75;
              position =
                let
                  self = niri-settings.outputs."HDMI-A-1";
                  builtin = niri-settings.outputs."eDP-1";

                  abs- = n: if n < 0 then n else -n;
                  logical-size = size: scale: {
                    width = builtins.floor (size.width / scale);
                    height = builtins.floor (size.height / scale);
                  };

                  self-logical-size = logical-size self.mode self.scale;
                  builtin-logical-size = logical-size builtin.mode builtin.scale;

                  center-offset = (self-logical-size.width / 2) - (builtin-logical-size.width / 2);
                in
                {
                  x = abs- center-offset;
                  y = -self-logical-size.height;
                };
              backdrop-color = "#001100";
            };
          };
          layout = {
            tab-indicator.width = 8;
            background-color = "transparent";
          };
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
              "Mod+W".action = toggle-column-tabbed-display;
              "Mod+C".action = center-window;
              "Mod+N".action = focus-window-down;
              "Mod+M".action = focus-window-up;
              "Mod+F".action = fullscreen-window;
              "Mod+Alt+F".action = toggle-windowed-fullscreen;

              "Mod+P".action = switch-focus-between-floating-and-tiling;
              "Mod+Alt+P".action = toggle-window-floating;

              "Mod+B".action = maximize-column;
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

              "Mod+Alt+H".action = move-column-left-or-to-monitor-left;
              "Mod+Alt+J".action = move-window-down-or-to-workspace-down;
              "Mod+Alt+K".action = move-window-up-or-to-workspace-up;
              "Mod+Alt+L".action = move-column-right-or-to-monitor-right;

              "Mod+Shift+J".action = move-workspace-down;
              "Mod+Shift+K".action = move-workspace-up;

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
          layer-rules = [
            {
              matches = [ { namespace = "^notifications$"; } ];
              block-out-from = "screencast";
            }
            # https://github.com/sodiboo/niri-flake/pull/1063
            {
              matches = [ { namespace = "^wallpaper$"; } ];
              place-within-backdrop = true;
            }
          ];
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
            {
              matches = [
                { app-id = "^org\.telegram\.desktop$"; }
                { app-id = "^QQ$"; }
              ];
              block-out-from = "screencast";
            }
            {
              matches = [
                {
                  app-id = "^QQ$";
                  title = "^(图片查看)|(视频播放)器$";
                }
                {
                  app-id = "^org\.telegram\.desktop$";
                  title = "^Media viewer$";
                }
                {
                  app-id = "^firefox$";
                  title = "^Picture-in-Picture$";
                }
              ];
              open-floating = true;
              default-window-height.proportion = 0.65;
              default-column-width.proportion = 0.65;
            }
            {
              matches = [ { is-window-cast-target = true; } ];
              focus-ring = {
                active.color = "#F38BA8";
                inactive.color = "#7D0D2D";
              };
              border.inactive.color = "#7D0D2D";
              shadow.color = "#7D0D2D70";
              tab-indicator = {
                active.color = "#F38BA8";
                inactive.color = "#7D0D2D";
              };
            }
            {
              matches = [ { app-id = "^btop$"; } ];
              default-column-width = {
                proportion = 0.8;
              };
            }
          ];
        };
    };

    home.packages = with pkgs; [
      libnotify

      wl-clipboard

      brightnessctl
      # wluma

      swaybg

      # wayland-utils
    ];

    systemd.user.services = {
      swaybg = {
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
      settings = {
        layer = "overlay";
        anchor = "top-right";
        background-color = "#686688ee";
        border-color = "#4C7899FF";
        border-radius = "2";
        border-size = "3";
        default-timeout = "7000";
        font = "monospace 13";
        height = "300";
        width = "500";
        margin = "10";
        padding = "5";

        # criteria
        "urgency=low" = {
          border-color = "#8be9fd";
        };
        "urgency=normal" = {
          border-color = "#bd93f9";
        };
        "urgency=high" = {
          border-color = "#ff5555";
          default-timeout = "0";
        };
      };
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

    services.darkman =
      let
        switchNiri = pkgs.writeShellApplication {
          name = "darkman-switch-niri";
          runtimeInputs = with pkgs; [ glib ];
          text = ''
            mode="$1"
            notify-send -c "system" " $mode mode"
            niri msg action do-screen-transition && \
            dconf write /org/gnome/desktop/interface/color-scheme "'prefer-$mode'"
          '';
        };
      in
      {
        enable = true;
        settings = {
          # Shanghai
          lat = 31.2;
          lng = 121.4;
          usegeoclue = false;
        };
        lightModeScripts = {
          gtk-portal = "${lib.getExe switchNiri} light";
        };
        darkModeScripts = {
          gtk-portal = "${lib.getExe switchNiri} dark";
        };
      };
    systemd.user.services.darkman.Install.After = [ "graphical-session.target" ];
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

  xdg.portal = {
    config = {
      common.default = [
        "gnome"
        "gtk"
      ];
      niri = {
        "org.freedesktop.impl.portal.Settings" = [ "darkman" ];
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      };
    };
    extraPortals = [ pkgs.darkman ];
  };

  qt = {
    enable = true;
    style = "adwaita";
    platformTheme = "qt5ct";
  };
}
