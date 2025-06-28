{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.sops) secrets;

  dns-cfg = config.services.smartdns;

  mkSecret = topic: k: {
    _secret = secrets."${k}-${topic}".path;
  };
  secretGenerator = topic: ss: (lib.genAttrs ss (mkSecret topic));
in
{
  networking.proxy.default = "http://127.0.0.1:7890/";

  sops.secrets = {
    server-odo = { };
    password-odo = { };
    method-odo = { };
    server-dc99 = { };
    password-dc99 = { };
    method-dc99 = { };
    server-mj = { };
    uuid-mj = { };
    Host-mj = { };
  };
  services.sing-box =
    let
      proxy-odo = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.odo";
          server_port = 17085;
        }
        (secretGenerator "odo" [
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
      proxy-dc99 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.dc99";
          server_port = 29137;
        }
        (secretGenerator "dc99" [
          "server"
          "password"
          "method"
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
        ];
        outbounds = [
          proxy-odo
          proxy-mj
          proxy-dc99
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
              address = "udp://127.0.0.1:${toString dns-cfg.bindPort}";
              detour = "direct";
            }
            {
              tag = "dns_block";
              address = "rcode://refused";
            }
          ];
          final = "dns_direct";
        };
        route = {
          auto_detect_interface = true;
          final = "proxy.odo";
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
                "geosite-education-cn"
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
              geosite-education-cn = "geosite-category-education-cn";
              geosite-bilibili = "geosite-bilibili";
              geosite-mozilla = "geosite-mozilla";
              geosite-chaoxing = "geosite-chaoxing";
              geosite-zhihuishu = "geosite-zhihuishu";
            });
        };
      };
    };
}
