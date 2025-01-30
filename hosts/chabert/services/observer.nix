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
            job_name = "cloudflared";
            static_configs = [{
              targets = [ "127.0.0.1:${cftPort}" ];
            }];
          }
          {
            job_name = "tailscale-${config.networking.hostName}";
            static_configs = [{
              targets = [ "100.100.100.100" ];
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
        ];
      };
    };
    prometheus.exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = nodePort;
      enabledCollectors = [
        "systemd"
        "logind"
        "processes"
      ];
    };
    tailscale.extraSetFlags = [
      "--webclient"
    ];
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
