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
in
{
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
        { type = "shadowsocks"; tag = "proxy"; server_port = 49148; }
        (secretGenerator [ "server" "password" "method" ])
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
        log.level = "info";
        inbounds = [
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "tun0";
            address = [ "172.19.0.1/30" "fd00::1/126" ];
            auto_route = true;
            strict_route = true;
            stack = "mixed";
            sniff = true;
          }
        ];
        outbounds = [
          proxy
          { tag = "direct"; type = "direct"; }
          { tag = "block"; type = "block"; }
          { type = "dns"; tag = "dns-out"; }
        ];
        dns = {
          servers = [
            {
              tag = "dns_proxy";
              address = "https://1.1.1.1/dns-query";
              detour = "direct";
            }
            {
              tag = "dns_direct";
              address = "https://223.5.5.5/dns-query";
              detour = "direct";
            }
            { tag = "dns_block"; address = "rcode://success"; }
          ];
          rules = [
            { outbound = [ "any" ]; server = "dns_direct"; }
            { geosite = [ "geolocation-!cn" ]; server = "dns_proxy"; }
            {
              geosite = [ "category-ads-all" ];
              server = "dns_block";
              disable_cache = true;
            }
          ];
          final = "dns_direct";
          independent_cache = true;
        };
        ntp = {
          enabled = true;
          server = "cn.ntp.org.cn";
          server_port = 123;
          interval = "30m";
          detour = "direct";
        };
        route = {
          auto_detect_interface = true;
          final = "proxy";
          rules = [
            { outbound = "dns-out"; protocol = "dns"; }
            { outbound = "direct"; geosite = [ "private" ]; }
            { outbound = "block"; geosite = [ "category-ads-all" ]; }
            {
              outbound = "direct";
              type = "logical";
              mode = "or";
              rules = [
                { geosite = [ "cn" ]; }
                { geoip = [ "cn" ]; }
              ];
            }
          ];
        };
      };
    };
}
