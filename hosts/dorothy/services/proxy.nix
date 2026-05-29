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

  proxy-final = "proxy.dc99";

  sing-box = pkgs.sing-box.overrideAttrs (
    finalAttrs: _prevAttrs: {
      version = "1.14.0-alpha.25";
      src = pkgs.fetchFromGitHub {
        owner = "SagerNet";
        repo = "sing-box";
        tag = "v${finalAttrs.version}";
        sha256 = "sha256-dAfYgKYx3nn1bNI5MnnA9VjsOg/XSJtfJwB3YIfDxN0=";
      };
      vendorHash = "sha256-W3xMbClnDrpTcxM8Lkc2lud4xX5MmHcT10/7WBNPXlc=";
    }
  );
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
      package = sing-box;
      settings = {
        log.level = "info";
        dns = {
          servers = [
            # {
            #   type = "udp";
            #   tag = "cf";
            #   server = "1.1.1.1";
            #   detour = proxy-final;
            # }
            # {
            #   type = "dhcp";
            #   tag = "cf";
            # }
            # {
            #   type = "h3";
            #   tag = "cf";
            #   server = "cloudflare-dns.com";
            #   domain_resolver = "ali";
            #   detour = proxy-final;
            # }
            {
              type = "local";
              tag = "cf";
            }
            {
              type = "tailscale";
              tag = "ts";
              endpoint = "ts-ep";
            }
          ];
          rules = [
            # {
            #   preferred_by = "ts";
            #   action = "route";
            #   server = "ts";
            # }
            {
              action = "route";
              domain_suffix = [ ".ts.net" ];
              preferred_by = "ts";
              server = "ts";
            }
          ];
          final = "cf";
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
            type = "http";
            tag = "http-in";
            listen = "::";
            listen_port = 7890;
          }
          {
            type = "tun";
            tag = "tun-in";
            interface_name = "singtun0";
            address = [
              "172.18.0.1/30"
              # "fdfe:dcba:9876::1/126"
            ];
            auto_route = true;
            auto_redirect = true;
            strict_route = true;
            dns_mode = "hijack";
            # dns_address = [ "100.100.100.100" ];
          }
        ];
        outbounds = [
          proxy-g12-6
          proxy-mj
          proxy-dc99
          # proxy-bwh99
          {
            type = "direct";
            tag = "direct-out";
            domain_resolver = "cf";
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
                    ".purejs.icu"
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
          default_domain_resolver = "cf";
        };
      };
    };

  systemd.services.sing-box = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
