{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.sops) secrets;

  cfg = config.services.sing-box;

  mkSecret = topic: k: {
    _secret = secrets."${k}-${topic}".path;
  };
  secretGenerator = topic: ss: (lib.genAttrs ss (mkSecret topic));
in
{
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
  sops.secrets.tailscaleAuthKey = { };

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
          proxy-odo
          proxy-mj
          proxy-dc99
          {
            tag = "direct";
            type = "direct";
          }
        ];
        endpoints = [
          {
            tag = "ts-ep";
            type = "tailscale";
            auth_key._secret = secrets.tailscaleAuthKey.path;
            state_directory = "/var/lib/tailscale";
            accept_routes = true;
          }
        ];
        dns = {
          servers = [
            {
              tag = "dns_direct";
              type = "local";
            }
            {
              type = "tailscale";
              tag = "tailscale";
              endpoint = "ts-ep";
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
          final = "proxy.odo";
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
              type = "logical";
              mode = "or";
              rules = [
                {
                  ip_cidr = "100.64.0.0/10";
                }
                {
                  domain_suffix = [ ".ts.net" ];
                }
              ];
            }

            {
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
                  ];
                }
              ]
              ++ (builtins.map (rs: { rule_set = rs; }) [
                "geoip-cn"
                "geosite-bank-cn"
                "geosite-education-cn"
                "geosite-bilibili"
                # even rust-lang.org
                # "geosite-mozilla"
                "geosite-chaoxing"
                "geosite-zhihuishu"
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

  preservation.preserveAt."/persist" = lib.mkIf cfg.enable {
    directories = [
      {
        directory = "/var/lib/tailscale";
        mode = "0755";
        user = config.systemd.services.sing-box.serviceConfig.User;
        group = config.systemd.services.sing-box.serviceConfig.Group;
      }
    ];
  };
}
