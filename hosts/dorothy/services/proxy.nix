{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.sops) secrets;

  mkSecret = topic: k: {
    _secret = secrets."${k}-${topic}".path;
  };
  secretGenerator = topic: ss: (lib.genAttrs ss (mkSecret topic));
in
{
  networking.proxy.default = "http://127.0.0.1:7890/";

  services.smartdns = {
    enable = false;
    settings = {
      server = [
        "223.5.5.5"
        "1.1.1.1"
        "8.8.8.8"
      ];
      server-tls = [
        "8.8.8.8:853"
        "1.1.1.1:853"
      ];
      server-https = "https://cloudflare-dns.com/dns-query https://223.5.5.5/dns-query";
    };
  };

  # networking.firewall.trustedInterfaces = [ "tun0" ];
  # boot.kernel.sysctl = {
  #   "net.ipv4.conf.all.forwarding" = true;
  #   "net.ipv6.conf.all.forwarding" = true;
  # };

  sops.secrets = {
    server-mie = { };
    password-mie = { };
    method-mie = { };
    server-mj = { };
    uuid-mj = { };
    Host-mj = { };
  };
  services.sing-box =
    let
      proxy-mie = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.mie";
          server_port = 17085;
        }
        (secretGenerator "mie" [
          "server"
          "password"
          "method"
        ])
      ];
      proxy-mj = lib.mergeAttrsList [
        {
          type = "vmess";
          tag = "proxy.mj";
          server_port = 16617;
          transport = {
            type = "ws";
            path = "/";
            headers = secretGenerator "mj" [ "Host" ];
          };
        }
        (secretGenerator "mj" [
          "server"
          "uuid"
        ])
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
          proxy-mie
          proxy-mj
          {
            tag = "direct";
            type = "direct";
          }
          {
            tag = "block";
            type = "block";
          }
          {
            tag = "dns-out";
            type = "dns";
          }
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
            {
              server = "dns_block";
              domain_suffix = [
                "tpstelemetry.tencent.com"
              ];
              domain = [
                "dataflow.biliapi.net"
                "hw-v2-web-player-tracker.biliapi.net"
              ];
            }
          ];
          final = "dns_direct";
        };
        route = {
          auto_detect_interface = true;
          final = "proxy.mie";
          rules = [
            {
              outbound = "dns-out";
              protocol = "dns";
            }

            {
              outbound = "direct";
              ip_is_private = true;
            }
            {
              outbound = "direct";
              type = "logical";
              mode = "or";
              rules = builtins.map (rs: { rule_set = rs; }) [
                "geoip-cn"
                "geosite-bank-cn"
                "geosite-bilibili"
                # even rust-lang.org
                # "geosite-mozilla"
                "geosite-chaoxing"
                "geosite-zhihuishu"
              ];
            }
            {
              outbound = "block";
              rule_set = "geosite-ads";
            }
          ];
          rule_set =
            let
              mkGeosite = tag: rule-set: {
                inherit tag;
                type = "local";
                format = "binary";
                path = "${pkgs.sing-geosite}/share/sing-box/rule-set/${rule-set}.srs";
              };
            in
            [
              {
                tag = "geoip-cn";
                type = "local";
                format = "binary";
                path = "${pkgs.sing-geoip}/share/sing-box/rule-set/geoip-cn.srs";
              }
            ]
            ++ (lib.mapAttrsToList mkGeosite {
              geosite-ads = "geosite-category-ads-all";
              geosite-bank-cn = "geosite-category-bank-cn";
              geosite-bilibili = "geosite-bilibili";
              geosite-mozilla = "geosite-mozilla";
              geosite-chaoxing = "geosite-chaoxing";
              geosite-zhihuishu = "geosite-zhihuishu";
            });
        };
      };
    };
}
