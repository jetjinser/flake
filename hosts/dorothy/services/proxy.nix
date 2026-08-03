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

  proxy-final = "proxy.g12-6";

  sing-box = pkgs.sing-box.overrideAttrs (
    finalAttrs: _prevAttrs: {
      version = "1.14.0-alpha.30";
      src = pkgs.fetchFromGitHub {
        owner = "SagerNet";
        repo = "sing-box";
        tag = "v${finalAttrs.version}";
        sha256 = "sha256-r/NRt2ndi4k51VLDTPEyALe45GBOiMSbDuPBLkDbbn4=";
      };
      vendorHash = "sha256-CuZS+9dwGTkoE9aL1Ua9IGm0wQFfA/5U5nms4TchVvI=";
    }
  );
in
{
  sops.secrets = {
    server-g12-6 = { };
    password-g12-6 = { };
    method-g12-6 = { };
    server-colo = { };
    password-colo = { };
    method-colo = { };
    server-mj = { };
    uuid-mj = { };
    Host-mj = { };
    server-green = { };
    password-green = { };
    method-green = { };
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
      proxy-colo = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.colo";
          server_port = 30880;
        }
        (secretGenerator "colo" [
          "server"
          "password"
          "method"
        ])
      ];
      proxy-green = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy.green";
          server_port = 2544;
        }
        (secretGenerator "green" [
          "server"
          "password"
          "method"
        ])
      ];
    in
    {
      enable = true;
      package = sing-box;
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
              preferred_by = "ts";
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
            address = [
              "172.18.0.1/30"
              "fdfe:dcba:9876::1/126"
            ];
            auto_route = true;
            auto_redirect = true;
            strict_route = true;
            stack = "mixed";
            dns_mode = "hijack";
          }
        ];
        outbounds = [
          proxy-g12-6
          proxy-mj
          proxy-colo
          proxy-green
          {
            type = "direct";
            tag = "direct-out";
            domain_resolver = "dns-local";
          }
        ];
        route = {
          rules = [
            { action = "sniff"; }
            {
              action = "route";
              outbound = "direct-out";
              protocol = "dns";
            }
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
