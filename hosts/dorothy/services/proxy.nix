{ config
, lib
, pkgs
, ...
}:

let
  inherit (config.sops) secrets;

  mkSecret = k: {
    _secret = secrets.${k}.path;
  };
  secretGenerator = with lib; flip genAttrs mkSecret;
in
{
  networking.proxy.default = "http://127.0.0.1:7890/";

  services.smartdns = {
    enable = false;
    settings = {
      server = [ "223.5.5.5" "1.1.1.1" "8.8.8.8" ];
      server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
      server-https = "https://cloudflare-dns.com/dns-query https://223.5.5.5/dns-query";
    };
  };

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
  services.sing-box =
    let
      proxy = lib.mergeAttrsList [
        { type = "shadowsocks"; tag = "proxy"; server_port = 17085; }
        (secretGenerator [ "server" "password" "method" ])
      ];
    in
    {
      enable = true;
      settings = {
        log.level = "warn";
        inbounds = [
          {
            type = "mixed";
            listen = "::";
            listen_port = 7890;
          }
          # {
          #   type = "tun";
          #   tag = "tun-in";
          #   interface_name = "tun0";
          #   address = [ "172.19.0.1/30" "fd00::1/126" ];
          #   auto_route = true;
          #   strict_route = true;
          #   stack = "mixed";
          #   sniff = true;
          # }
        ];
        outbounds = [
          proxy
          { tag = "direct"; type = "direct"; }
          { tag = "block"; type = "block"; }
          { tag = "dns-out"; type = "dns"; }
        ];
        dns = {
          servers = [
            {
              tag = "dns_direct";
              # TODO: local dns
              address = "https://223.5.5.5/dns-query";
              detour = "direct";
            }
            {
              tag = "dns_block";
              address = "rcode://refused";
            }
          ];
          rules = [
            { server = "dns_direct"; outbound = [ "any" ]; }
            {
              server = "dns_block";
              domain_suffix = [
                "tpstelemetry.tencent.com"
              ];
            }
          ];
          final = "dns_direct";
        };
        route = {
          auto_detect_interface = true;
          final = "proxy";
          rules = [
            { outbound = "dns-out"; protocol = "dns"; }

            { outbound = "direct"; ip_is_private = true; }
            { outbound = "direct"; rule_set = "geoip-cn"; }

            { outbound = "block"; rule_set = "geosite-ads"; }
          ];
          rule_set = [
            {
              tag = "geoip-cn";
              type = "local";
              format = "binary";
              path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
            }
            {
              tag = "geosite-ads";
              type = "local";
              format = "binary";
              path = "${pkgs.sing-geosite}/share/sing-box/rule-set/geosite-category-ads-all.srs";
            }
          ];
        };
      };
    };
}
