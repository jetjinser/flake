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

  proxy-final = "proxy.g12-4";
in
{
  sops.secrets = {
    server-g12-4 = { };
    server-g12-6 = { };
    password-g12 = { };
    method-g12 = { };

    server-mj = { };
    uuid-mj = { };
    Host-mj = { };

    server-bwh99 = { };
    server_name-bwh99 = { };
    password-bwh99 = { };
    username-bwh99 = { };

    server-vpst4 = { };
    server-vpst6 = { };
    password-vpst = { };
    method-vpst = { };

    server-bwh4 = { };
    server-bwh6 = { };
    password-bwh = { };
    method-bwh = { };

    server-greenq4 = { };
    server-greenq6 = { };
    password-greenq = { };
    method-greenq = { };
  };
  sops.secrets.tailscaleAuthKey = { };

  services.sing-box =
    let
      proxy-g12-4 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.g12-4";
          server_port = 4505;
        }
        (secretGenerator "g12-4" [ "server" ])
        (secretGenerator "g12" [
          "password"
          "method"
        ])
      ];
      proxy-g12-6 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.g12-6";
          server_port = 4505;
        }
        (secretGenerator "g12-6" [ "server" ])
        (secretGenerator "g12" [
          "password"
          "method"
        ])
      ];
      proxy-vpst4 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.vpst4";
          server_port = 23172;
        }
        (secretGenerator "vpst4" [ "server" ])
        (secretGenerator "vpst" [
          "password"
          "method"
        ])
      ];
      proxy-vpst6 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.vpst6";
          server_port = 23172;
        }
        (secretGenerator "vpst6" [ "server" ])
        (secretGenerator "vpst" [
          "password"
          "method"
        ])
      ];
      proxy-bwh4 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.bwh4";
          server_port = 58559;
        }
        (secretGenerator "bwh4" [ "server" ])
        (secretGenerator "bwh" [
          "password"
          "method"
        ])
      ];
      proxy-bwh6 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.bwh6";
          server_port = 58559;
        }
        (secretGenerator "bwh6" [ "server" ])
        (secretGenerator "bwh" [
          "password"
          "method"
        ])
      ];
      proxy-greenq4 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.greenq4";
          server_port = 45665;
        }
        (secretGenerator "greenq4" [ "server" ])
        (secretGenerator "greenq" [
          "password"
          "method"
        ])
      ];
      proxy-greenq6 = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.greenq6";
          server_port = 45665;
        }
        (secretGenerator "greenq6" [ "server" ])
        (secretGenerator "greenq" [
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
      proxy-bwh99 = lib.mergeAttrsList [
        {
          type = "naive";
          tag = "proxy.bwh99";
          server_port = 57957;
          udp_over_tcp.enabled = true;
          quic = true;
          tls = {
            enabled = true;
          }
          // (secretGenerator "bwh99" [ "server_name" ]);
        }
        (secretGenerator "bwh99" [
          "server"
          "password"
          "username"
        ])
      ];
    in
    {
      enable = true;
      settings = {
        log.level = "warn";
        dns = {
          servers = [
            {
              type = "https";
              tag = "dns-remote";
              server = "1.1.1.1";
              path = "/dns-query";
              detour = proxy-final;
            }
            {
              type = "local";
              tag = "dns-local";
              detour = "direct-out";
            }
            {
              type = "tailscale";
              tag = "ts";
              endpoint = "ts-ep";
            }
          ];
          rules = [
            {
              action = "route";
              domain_suffix = [ ".ts.net" ];
              # 1.14 upcoming config item
              # preferred_by = "ts";
              server = "ts";
            }
            {
              action = "route";
              rule_set = [ "geosite-cn" ];
              server = "dns-local";
            }
            {
              action = "route";
              domain_suffix = [
                ".2jk.pw"
                ".bhu.social"
                ".zoom.us"
                "spritely.institute"
              ];
              server = "dns-local";
            }
          ];
          strategy = "ipv4_only";
          final = "dns-remote";
        };
        endpoints = [
          {
            tag = "ts-ep";
            type = "tailscale";
            auth_key._secret = secrets.tailscaleAuthKey.path;
            accept_routes = true;
          }
        ];
        inbounds = [
          {
            type = "mixed";
            tag = "mixed-in";
            listen = "::";
            listen_port = 7890;
          }
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "singtun0";
            mtu = 1400;
            address = [
              "172.18.0.1/30"
              "fdfe:dcba:9876::1/126"
            ];
            auto_route = true;
            auto_redirect = true;
            strict_route = true;
            stack = "mixed";
            # 1.14 upcoming config item
            # dns_mode = "hijack";
          }
        ];
        outbounds = [
          proxy-g12-4
          proxy-g12-6
          proxy-vpst4 # blocked
          proxy-vpst6
          proxy-bwh4
          proxy-bwh6
          proxy-greenq4
          proxy-greenq6
          proxy-mj
          proxy-bwh99
          {
            type = "direct";
            tag = "direct-out";
            domain_resolver = "dns-local";
          }
        ];
        route = {
          rules = [
            # { action = "sniff"; }
            # {
            #   action = "route";
            #   outbound = "direct-out";
            #   protocol = "dns";
            # }
            {
              action = "route";
              outbound = "ts-ep";
              ip_cidr = "100.64.0.0/10";
            }

            {
              action = "route";
              outbound = proxy-final;
              domain_suffix = [
                # some of them are in geosite-cn
                "googleapis.com"
                "gstatic.com"
                "googletagmanager.com"
                "kimi.com"
                "livehouse.2jk.pw"
              ];
            }
            {
              outbound = "direct-out";
              type = "logical";
              mode = "or";
              rules = [
                # direct rule
                {
                  domain_suffix = [
                    ".2jk.pw"
                    ".bhu.social"
                    # ".purejs.icu"
                    ".zoom.us"
                    "spritely.institute"
                  ];
                }
                {
                  rule_set = [
                    "geoip-cn"
                    "geosite-cn"
                    "geosite-bank-cn"
                    "geosite-education-cn"
                    "geosite-bilibili"
                    "geosite-chaoxing"
                    "geosite-bytedance"
                  ];
                }
              ];
            }

            {
              action = "reject";
              rule_set = "geosite-ads";
            }
          ];
          rule_set =
            let
              mkGeosite = tag: rule-set: {
                type = "local";
                inherit tag;
                format = "binary";
                path = "${pkgs.sing-geosite}/share/sing-box/rule-set/${rule-set}.srs";
              };
            in
            [
              {
                type = "local";
                tag = "geoip-cn";
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
          final = proxy-final;
          auto_detect_interface = true;
          default_domain_resolver = "dns-remote";
        };
      };
    };

  systemd.services.sing-box = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
