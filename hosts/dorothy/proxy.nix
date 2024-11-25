{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;

  mkSecret = k: {
    _secret = secrets.${k}.path;
  };
  secretGenerator = with lib; flip genAttrs mkSecret;

  nameservers = {
    AliDNS = "223.5.5.5";
    CloudFlare = "1.1.1.1";
  };
in
{
  # NOTE: global, since SwitchyOmega does not work on my Firefox
  # networking.proxy.default = "http://127.0.0.1:7890/";

  networking.firewall.trustedInterfaces = [ "tun0" ];
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

  sops.secrets = {
    server = { };
    password = { };
    method = { };
  };
  systemd.services.sing-box.wantedBy = lib.mkForce [ ];
  services.sing-box =
    let
      proxy = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy";
          # server_port = 28018;
          server_port = 49148;
        }
        (secretGenerator
          [
            "server"
            "password"
            "method"
          ])
        {
          multiplex = {
            enabled = true;
            protocol = "h2mux";
            max_streams = 16;
            padding = false;
          };
        }
      ];
    in
    {
      enable = true;
      settings = {
        log.level = "warn";
        inbounds = [
          # {
          #   type = "mixed";
          #   listen = "::";
          #   listen_port = 7890;
          # }
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "tun0";
            address = [
              "172.19.0.1/30"
              "fd00::1/126"
            ];
            auto_route = true;
            strict_route = true;
            stack = "system";
            sniff = true;
          }
        ];
        outbounds = [
          proxy
          {
            tag = "direct";
            type = "direct";
          }
          {
            tag = "block";
            type = "block";
          }
          {
            type = "dns";
            tag = "dns-out";
          }
        ];
        dns = {
          servers = [
            {
              tag = "AliDNS";
              address = "https://${nameservers.AliDNS}/dns-query";
              address_strategy = "prefer_ipv4";
              detour = "direct";
            }
            {
              tag = "CloudFlare";
              address = "https://${nameservers.CloudFlare}/dns-query";
              detour = "direct";
            }
            {
              tag = "block";
              address = "rcode://success";
            }
          ];
          rules = [
            {
              geosite = [ "cn" ];
              server = "AliDNS";
              disable_cache = false;
            }
            {
              geosite = [ "category-ads-all" ];
              server = "block";
              disable_cache = true;
            }
          ];
          final = "CloudFlare";
        };
        route = {
          auto_detect_interface = true;
          final = "direct";
          rules = [
            { outbound = "dns-out"; protocol = "dns"; }
            { outbound = "direct"; geosite = [ "private" ]; }
            {
              outbound = "proxy";
              type = "logical";
              mode = "or";
              rules = [
                { geosite = [ "geolocation-!cn" ]; }
                { geoip = [ "cn" ]; invert = true; }
              ];
            }
            {
              outbound = "direct";
              type = "logical";
              mode = "and";
              rules = [
                { geosite = [ "cn" ]; }
                { geoip = [ "cn" ]; }
              ];
            }
          ];
        };
      };
    };

  systemd.services.sing-box.serviceConfig.UMask = "0077";
}
