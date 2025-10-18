{
  config,
  pkgs,
  lib,
  ...
}:

let
  enable = false;
  domain = "h.2jk.pw";

  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  cfg = config.services.home-assistant;
in
{
  environment.systemPackages = with pkgs; [ hddtemp ];

  services.home-assistant = {
    inherit enable;
    extraComponents = [
      # Components required to complete the onboarding
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      # Recommended for fast zlib compression
      # https://www.home-assistant.io/integrations/isal
      "isal"

      # keep-sorted start
      "ai_task"
      "date"
      "device_tracker"
      "media_player"
      "mobile_app"
      "moon"
      "open_router"
      "plex"
      "raspberry_pi"
      "remote_calendar"
      "spotify"
      "sun"
      "tailscale"
      "telegram"
      "telegram_bot"
      "xiaomi"
      # keep-sorted end
    ];
    customComponents = builtins.attrValues (
      lib.packagesFromDirectoryRecursive {
        inherit (pkgs) callPackage;
        directory = ../ha-components;
      }
    );
    config = {
      # lovelace.mode = "yaml";
      http = {
        server_host = [ "127.0.0.1" ];
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
      homeassistant = {
        name = hostName;
        unit_system = "metric";
      };
      device_tracker = [
        {
          platform = "xiaomi";
          host = throw "TODO";
          password = throw "TODO";
        }
      ];
    };
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      auto-entities
      bubble-card
    ];
    lovelaceConfig = {
      title = "JK@Home";
      views = [
        {
          type = "sections";
          title = "宿舍";
          path = "dormitory";
          icon = "mdi:home-assistant";
          badges = [
            {
              type = "entity";
              entity = "sensor.backup_backup_manager_state";
              color = "red";
            }
            {
              type = "entity";
              entity = "sensor.backup_backup_manager_state";
              color = "indigo";
            }
            {
              type = "entity";
              entity = "device_tracker.nixos";
            }
          ];
          sections = [
            {
              cards = [
                {
                  type = "heading";
                  heading = "屋内";
                  icon = "mdi:ceiling-light";
                  badges = [
                    {
                      type = "entity";
                      entity = "sensor.backup_backup_manager_state";
                      show_state = false;
                      color = "red";
                    }
                  ];
                }
                {
                  type = "weather-forecast";
                  entity = "weather.forecast_wo_de_jia";
                }
                {
                  type = "custom:auto-entities";
                  card = {
                    type = "entities";
                    title = "路由器连接设备";
                  };
                  filter = {
                    include = [
                      {
                        domain = "device_tracker";
                        attributes = {
                          scanner = "XiaomiDeviceScanner";
                        };
                      }
                    ];
                  };
                }
              ];
            }
            {
              cards = [
                {
                  type = "heading";
                  heading = "桌前";
                  icon = "mdi:desk-lamp";
                  badges = [
                    {
                      type = "entity";
                      entity = "sensor.backup_backup_manager_state";
                      show_state = false;
                      color = "blue";
                    }
                  ];
                }
                {
                  type = "markdown";
                  title = "TODO";
                  content = "Placeholder";
                }
              ];
            }
          ];
        }
      ];
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    ha-key = {
      owner = config.services.caddy.user;
      inherit (config.services.caddy) group;
      mode = "0400";
    };
  };
  services.caddy = {
    virtualHosts = lib.mkIf cfg.enable {
      ${domain} = {
        extraConfig = ''
          tls ${../../../assets/ha.crt} ${secrets.ha-key.path}
          reverse_proxy http://127.0.0.1:${toString cfg.config.http.server_port} {
            header_down X-Real-IP {http.request.remote}
            header_down X-Forwarded-For {http.request.remote}
          }
        '';
      };
    };
  };
}
