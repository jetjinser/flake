{ config
, lib
, ...
}:

let
  # TODO: route rules
  enable = true;

  inherit (config.sops) secrets;

  mkSecret = k: {
    _secret = secrets.${k}.path;
  };
  secretGenerator = with lib; flip genAttrs mkSecret;
in
{
  imports = [
    ../../../modules/darwinModules
  ];

  servicy.sing-box =
    let
      mie-proxy = lib.mergeAttrsList [
        {
          type = "vmess";
          tag = "mie-proxy";
          server_port = 31345;
        }
        (secretGenerator
          [
            "server"
            "uuid"
            "security"
          ])
      ];
    in
    {
      inherit enable;
      settings = {
        # dns = {
        #   final = "dns_direct";
        #   rules = [
        #     { outbound = "any"; server = "dns_resolver"; }
        #     { rule_set = "geosite"; server = "dns_proxy"; }
        #   ];
        #   servers = [
        #     {
        #       address = "https://1.1.1.1/dns-query";
        #       address_resolver = "dns_resolver";
        #       detour = "proxy";
        #       strategy = "ipv4_only";
        #       tag = "dns_proxy";
        #     }
        #     {
        #       address = "https://dns.alidns.com/dns-query";
        #       address_resolver = "dns_resolver";
        #       detour = "direct";
        #       strategy = "ipv4_only";
        #       tag = "dns_direct";
        #     }
        #     { address = "223.5.5.5"; detour = "direct"; tag = "dns_resolver"; }
        #     { address = "rcode://success"; tag = "dns_block"; }
        #   ];
        # };
        inbounds = [
          {
            type = "mixed";
            listen = "::";
            listen_port = 7890;
          }
        ];
        outbounds = [ mie-proxy ];
      };
    };
}
