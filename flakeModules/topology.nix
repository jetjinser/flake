{
  inputs,
  config,
  lib,
  ...
}:

let
  inherit (config) flake;
in
{
  imports = [ inputs.nix-topology.flakeModule ];

  perSystem = _: {
    topology.modules = [
      {
        inherit (flake) nixosConfigurations;
      }
      (
        { config, ... }:
        let
          tlib = config.lib.topology;
        in
        {
          nodes.internet-at-dormitory = tlib.mkInternet {
            connections = tlib.mkConnection "router-dormitory" "wan1";
          };
          nodes.internet-at-mie = tlib.mkInternet {
            connections = tlib.mkConnection "miecloud" "ens18";
          };
          nodes.internet-at-aliyun = tlib.mkInternet {
            connections = tlib.mkConnection "chabert" "ens3";
          };
          nodes.internet-at-jdcloud = tlib.mkInternet {
            connections = tlib.mkConnection "cosimo" "ens5";
          };

          nodes.router-dormitory = tlib.mkRouter "Router@Dormitory" {
            info = "Redmi AC2100";
            image = ./images/Redmi_AC2100.png;
            renderer.preferredType = "image";
            interfaceGroups = [
              [
                "eth1"
                "eth2"
                "eth3"
                "eth4"
                "wlan"
              ]
              [ "wan1" ]
            ];

            interfaces.wan1 = {
              network = "dormitory";
              gateways = [ "192.168.31.1" ];
            };

            connections.wlan = [
              (tlib.mkConnection "dorothy" "wlp1s0")
              (tlib.mkConnection "karenina" "wlan0")
            ];

            interfaces.wlan.network = "dormitory";

            connections.eth1 = tlib.mkConnection "bendemann" "end0";
            interfaces.eth1.network = "dormitory";

            connections.eth2 = tlib.mkConnection "karenina" "end0";
            interfaces.eth2.network = "dormitory";

            connections.eth3 = tlib.mkConnection "barnabas" "br-lan";
            interfaces.eth3.network = "dormitory";
          };

          nodes.bendemann.interfaces."end0" = { };

          networks.dormitory = {
            name = "University Dormitory";
            cidrv4 = "192.168.31.0/24";
          };

          #### tailscale

          networks.tailscale = {
            name = "Tailscale Net";
            cidrv4 = "100.0.0.0/8";
          };
          nodes.chabert = {
            interfaces.tailscale0 = {
              network = "tailscale";
              physicalConnections = [
                (tlib.mkConnection "dorothy" "tailscale0")
                (tlib.mkConnection "karenina" "tailscale0")
                (tlib.mkConnection "miecloud" "tailscale0")
                (tlib.mkConnection "cosimo" "tailscale0")
              ];
            };
            interfaces.ens3 = { };
            services.grafana = {
              info = lib.mkForce "observer.statique.icu";
              details = lib.mkForce { };
            };
          };
          nodes.miecloud = {
            interfaces.tailscale0 = { };
            services = {
              jellyfin.info = "media.purejs.icu";
              jellyseerr.info = "discovery.purejs.icu";
              prowlarr.info = "prowlarr.purejs.icu";
              radarr.info = "radarr.purejs.icu";
            };
          };
          nodes.cosimo = {
            interfaces = {
              tailscale0 = { };
              ens5 = { };
            };
            services.wakapi = {
              name = "Wakapi";
              info = "waka.purejs.icu";
              icon = ./images/wakapi_logo.svg;
            };
          };
          nodes.karenina.hardware.info = "RaspberryPi";
          nodes.dorothy = {
            name = "💻 dorothy";
            hardware.info = "Lenovo XiaoXin Pro 14";
          };
        }
      )
    ];
  };
}
