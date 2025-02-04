{ lib
, config
, flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;

  cfg = config.services;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  StatiqueTunnelID = "a678f104-f65c-486b-9a55-f07ac00d70b8";
  statique = "statique.icu";
  subdomain = "observer";

  grafanaPort = 3000;

  vmPort = "8001";

  cftPort = "9001";
  nodePort = 9002;
in
{
  sops.secrets = {
    statiqueTunnelJson.owner = users.cloudflared.name;
    grafanaPWD.owner = users.grafana.name;
  };

  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = grafanaPort;
          enable_gzip = true;
          enforce_domain = true;
          domain = "${subdomain}.${statique}";
        };
        # TODO: use PostgreSQL instead of default sqlite3
        # database = {};
        security = {
          cookie_secure = true;
          admin_user = myself;
          admin_password = "$__file{${secrets.grafanaPWD.path}}";
          admin_email = "aimer@purejs.icu";
        };
      };
      provision = {
        enable = true;
        datasources.settings = {
          apiVersion = 1;
          datasources = [{
            name = "VictoriaMetrics";
            url = "http://${cfg.victoriametrics.listenAddress}";
            type = "prometheus";
          }];
        };
        # dashboards = {
        #   settings = {
        #     apiVersion = 1;
        #     providers = [ ];
        #   };
        # };
      };
    };
    victoriametrics = {
      enable = true;
      listenAddress = "127.0.0.1:${vmPort}";
      retentionPeriod = "30d";
      prometheusConfig = {
        scrape_configs = [
          {
            job_name = "cloudflared-at-sheep";
            static_configs = [{
              targets = [ "127.0.0.1:${cftPort}" ];
            }];
          }

          {
            job_name = "jellyfin-at-sheep";
            static_configs = [{
              targets = [ "miecloud:8096" ];
            }];
          }
          {
            job_name = "radarr-at-sheep";
            static_configs = [{
              targets = [
                "127.0.0.1:${toString cfg.prometheus.exporters.exportarr-radarr.port}"
              ];
            }];
          }
          {
            job_name = "prowlarr-at-sheep";
            static_configs = [{
              targets = [
                "127.0.0.1:${toString cfg.prometheus.exporters.exportarr-prowlarr.port}"
              ];
            }];
          }
          {
            job_name = "bazarr-at-sheep";
            static_configs = [{
              targets = [
                "127.0.0.1:${toString cfg.prometheus.exporters.exportarr-bazarr.port}"
              ];
            }];
          }

          # TODO: auto-wiring
          {
            job_name = "tailscale-${config.networking.hostName}";
            static_configs = [{
              targets = [ "100.100.100.100" ];
            }];
          }
          {
            job_name = "tailscale-sheep";
            static_configs = [{
              targets = [ "miecloud:5252" ];
            }];
          }
          {
            job_name = "tailscale-cosimo";
            static_configs = [{
              targets = [ "cosimo:5252" ];
            }];
          }

          {
            job_name = "node-exporter-${config.networking.hostName}";
            static_configs = [{
              targets = [ "127.0.0.1:${toString nodePort}" ];
              labels.type = "node";
              labels.host = config.networking.hostName;
            }];
          }
          {
            job_name = "node-exporter-miecloud";
            static_configs = [{
              targets = [ "miecloud:${toString nodePort}" ];
              labels.type = "node";
              labels.host = "miecloud";
            }];
          }
        ];
      };
    };
  };

  users.groups.exportarr = { };
  sops.secrets = {
    radarrAPIKey.group = "exportarr";
    prowlarrAPIKey.group = "exportarr";
    bazarrAPIKey.group = "exportarr";
  };
  systemd.services = {
    prometheus-exportarr-radarr-exporter.serviceConfig.SupplementaryGroups = [ "exportarr" ];
    prometheus-exportarr-prowlarr-exporter.serviceConfig.SupplementaryGroups = [ "exportarr" ];
    prometheus-exportarr-bazarr-exporter.serviceConfig.SupplementaryGroups = [ "exportarr" ];
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = nodePort;
      enabledCollectors = [
        "systemd"
        "logind"
        "processes"
      ];
      extraFlags = [
        "--collector.systemd.enable-start-time-metrics"
      ];
    };
    exportarr-radarr = {
      enable = true;
      url = "http://miecloud:7878";
      port = 9708;
      apiKeyFile = secrets.radarrAPIKey.path;
    };
    exportarr-prowlarr = {
      enable = true;
      url = "http://miecloud:9696";
      port = 9709;
      apiKeyFile = secrets.prowlarrAPIKey.path;
    };
    exportarr-bazarr = {
      enable = true;
      url = "http://miecloud:6767";
      port = 9710;
      apiKeyFile = secrets.bazarrAPIKey.path;
    };
  };

  services.cloudflared =
    let
      serveIng = domain: subdomain: port: {
        "${subdomain}.${domain}" = "http://127.0.0.1:${toString port}";
      };
      serveStatiqueIng = serveIng statique;
    in
    {
      tunnels = {
        ${StatiqueTunnelID} = {
          credentialsFile = secrets.statiqueTunnelJson.path;
          default = "http_status:404";
          ingress = lib.concatMapAttrs serveStatiqueIng {
            ${subdomain} = cfg.grafana.settings.server.http_port;
          };
        };
      };
    };
  systemd.services."cloudflared-tunnel-${StatiqueTunnelID}".environment = {
    TUNNEL_METRICS = "127.0.0.1:${cftPort}";
  };
}
