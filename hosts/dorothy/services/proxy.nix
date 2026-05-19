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
  sops.secrets = {
    server-g12-6 = { };
    password-g12-6 = { };
    method-g12-6 = { };
    server-dc99 = { };
    password-dc99 = { };
    method-dc99 = { };
    server-mj = { };
    uuid-mj = { };
    Host-mj = { };
    server-bwh99 = { };
    username-bwh99 = { };
    password-bwh99 = { };
  };
  sops.secrets.tailscaleAuthKey = { };

  services.sing-box =
    let
      proxy-g12-6 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.g12-6";
          server_port = 4505;
        }
        (secretGenerator "g12-6" [
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
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "singtun";
            address = [
              "172.18.0.1/30"
              "fdfe:dcba:9876::1/126"
            ];
            mtu = 9000;
            auto_route = true;
            auto_redirect = true;
            route_address = [
              "0.0.0.0/1"
              "128.0.0.0/1"
              "::/1"
              "8000::/1"
            ];
            platform = {
              http_proxy = {
                enabled = true;
                server = "127.0.0.1";
                server_port = 7890;
              };
            };
            stack = "mixed";
          }
        ];
        outbounds = [
          proxy-g12-6
          proxy-mj
          proxy-dc99
          # proxy-bwh99
          {
            tag = "direct";
            type = "direct";
            domain_resolver = {
              server = "dns_direct";
              strategy = "prefer_ipv4";
            };
          }
        ];
        endpoints = [
          {
            tag = "ts-ep";
            type = "tailscale";
            auth_key._secret = secrets.tailscaleAuthKey.path;
            accept_routes = true;
          }
        ];
        dns = {
          servers = [
            {
              tag = "dns_direct";
              type = "local";
            }
          ];
          rules = [
            {
              domain = [ ];
              action = "predefined";
              rcode = "REFUSED";
            }
          ];
          final = "dns_direct";
        };
        route = {
          auto_detect_interface = true;
          final = "proxy.dc99";
          default_domain_resolver = {
            server = "dns_direct";
          };
          rules = [
            {
              action = "hijack-dns";
              protocol = "dns";
            }
            {
              outbound = "ts-ep";
              ip_cidr = "100.64.0.0/10";
            }

            {
              action = "route";
              outbound = "direct";
              ip_is_private = true;
            }
            {
              outbound = "direct";
              type = "logical";
              mode = "or";
              rules = [
                {
                  domain_suffix = [
                    ".2jk.pw"
                    ".bhu.social"
                    ".purejs.icu"
                    ".zoom.us"
                    "spritely.institute"
                  ];
                }
              ]
              ++ (builtins.map (rs: { rule_set = rs; }) [
                "geoip-cn"
                "geosite-cn"
                "geosite-bank-cn"
                "geosite-education-cn"
                "geosite-bilibili"
                "geosite-chaoxing"
                "geosite-bytedance"
              ]);
            }
            {
              action = "reject";
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
              geosite-cn = "geosite-cn";
              geosite-ads = "geosite-category-ads-all";
              geosite-bank-cn = "geosite-category-bank-cn";
              geosite-education-cn = "geosite-category-education-cn";
              geosite-bilibili = "geosite-bilibili";
              geosite-chaoxing = "geosite-chaoxing";
              geosite-bytedance = "geosite-bytedance";
            });
        };
      };
    };

  systemd.services.sing-box = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
