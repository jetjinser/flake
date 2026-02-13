# https://github.com/ryan4yin/nix-config/blob/7fd3baca0f651a5b9b1438f4e74620f59716d5bf/hosts/12kingdoms-suzu/microvm/suzi/networking.nix

{
  flake,
  config,
  ...
}:

let
  inherit (flake.config.symbols.machines.nanopi-r2s) host;

  mainGateway = "192.168.31.1";
  nameservers = {
    DNSPod = "119.29.29.29";
    AliDNS = "223.5.5.5";
    CloudFlare = "1.1.1.1";
  };

  ipv4WithMask = "${host}/24";
  dhcpRange = {
    start = "192.168.31.101";
    end = "192.168.31.255";
  };
in
{
  boot.kernelModules = [
    "tcp_bbr"
    # preload to make sysctl options available
    "nf_conntrack"
  ];
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";

    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    # "net.ipv6.conf.all.accept_ra" = 0;
    # "net.ipv6.conf.all.autoconf" = 0;
    # "net.ipv6.conf.all.use_tempaddr" = 0;

    "net.ipv4.conf.br0.rp_filter" = 1;
    "net.ipv4.conf.br0.send_redirects" = 0;
  };

  networking = {
    useNetworkd = true;

    useDHCP = false;
    networkmanager.enable = false;
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    nat.enable = false;
    firewall.enable = false; # No local firewall.

    nftables = {
      enable = true;
      # rulesetFile = ./ruleset.nft;
    };
  };

  # sops.secrets = {
  #   server = { };
  #   password = { };
  #   method = { };
  # };
  # services.sing-box = {
  #   enable = true;
  #   settings =
  #     let
  #       mkSecret = k: {
  #         _secret = secrets.${k}.path;
  #       };
  #       secretGenerator = with lib; flip genAttrs mkSecret;
  #       proxy = lib.mergeAttrsList [
  #         {
  #           type = "shadowsocks";
  #           tag = "proxy";
  #           server_port = 49148;
  #         }
  #         (secretGenerator [
  #           "server"
  #           "password"
  #           "method"
  #         ])
  #         {
  #           multiplex = {
  #             enabled = true;
  #             protocol = "h2mux";
  #             max_streams = 16;
  #             padding = false;
  #           };
  #         }
  #       ];
  #     in
  #     {
  #       log.level = "warn";
  #       inbounds = [
  #         {
  #           type = "tproxy";
  #           tag = "tproxy0";
  #           listen = "::";
  #           listen_port = 7890;
  #           tcp_fast_open = true;
  #           udp_fragment = true;
  #           sniff = true;
  #         }
  #       ];
  #       outbounds = [
  #         proxy
  #         {
  #           type = "direct";
  #           tag = "direct";
  #         }
  #         {
  #           type = "block";
  #           tag = "block";
  #         }
  #         {
  #           type = "dns";
  #           tag = "dns-out";
  #         }
  #       ];
  #       dns = {
  #         servers = [
  #           {
  #             tag = "DNSPod";
  #             address = "https://${nameservers.DNSPod}/dns-query";
  #             address_strategy = "prefer_ipv4";
  #             strategy = "ipv4_only";
  #             detour = "direct";
  #           }
  #           {
  #             tag = "AliDNS";
  #             address = "https://${nameservers.AliDNS}/dns-query";
  #             address_strategy = "prefer_ipv4";
  #             strategy = "ipv4_only";
  #             detour = "direct";
  #           }
  #           {
  #             tag = "CloudFlare";
  #             address = "https://${nameservers.CloudFlare}/dns-query";
  #             strategy = "ipv4_only";
  #             detour = "direct";
  #           }
  #           {
  #             tag = "block";
  #             address = "rcode://success";
  #           }
  #         ];
  #         rules = [
  #           {
  #             geosite = [ "cn" ];
  #             domain_suffix = [ ".cn" ];
  #             server = "AliDNS";
  #             disable_cache = false;
  #           }
  #           {
  #             geosite = [ "category-ads-all" ];
  #             server = "block";
  #             disable_cache = true;
  #           }
  #         ];
  #         final = "CloudFlare";
  #       };
  #       route = {
  #         rules = [
  #           {
  #             protocol = "dns";
  #             outbound = "dns-out";
  #           }
  #           {
  #             geosite = [ "category-ads-all" ];
  #             outbound = "block";
  #           }
  #           {
  #             type = "logical";
  #             mode = "or";
  #             rules = [
  #               { geosite = [ "geolocation-!cn" ]; }
  #               {
  #                 geoip = [ "cn" ];
  #                 invert = true;
  #               }
  #             ];
  #             outbound = "proxy";
  #           }
  #         ];
  #         final = "direct";
  #         default_mark = 2;
  #       };
  #     };
  # };
  # systemd.services.sing-box.serviceConfig.UMask = "0077";

  systemd.network = {
    enable = true;
    # netdevs = {
    #   # Create the bridge interface
    #   "20-br0" = {
    #     netdevConfig = {
    #       Kind = "bridge";
    #       Name = "br0";
    #     };
    #   };
    # };
    # nat = {
    #   enable = false;
    #   externalInterface = "";
    # };
    # This is a bypass router, so we do not need a wan interface here.
    networks = {
      "10-wan" = {
        matchConfig.Name = "eth* en*";
        address = [ ipv4WithMask ];
        routes = [ { Gateway = mainGateway; } ];
        networkConfig.DNS = "119.29.29.29 223.5.5.5 1.1.1.1";
      };
      # "30-lan0" = {
      #   # match the interface by type
      #   matchConfig.Type = "ether";
      #   # Connect to the bridge
      #   networkConfig = {
      #     Bridge = "br0";
      #     ConfigureWithoutCarrier = true;
      #   };
      #   linkConfig.RequiredForOnline = "enslaved";
      # };
      # Configure the bridge device we just created
      # "40-br0" = {
      #   matchConfig.Name = "br0";
      #   address = [
      #     # configure addresses including subnet mask
      #     ipv4WithMask # forwards all traffic to the gateway except for the router address itself
      #   ];
      #   routes = [
      #     # forward all traffic to the main gateway
      #     { Gateway = mainGateway; }
      #   ];
      #   bridgeConfig = { };
      #   linkConfig.RequiredForOnline = "routable";
      # };
      # "tproxy" = {
      #   matchConfig.Name = "lo";
      #   routes = [
      #     {
      #       Type = "local";
      #       Scope = "host";
      #       Destination = "0.0.0.0/0";
      #       Table = 233;
      #     }
      #     {
      #       Type = "local";
      #       Scope = "host";
      #       Destination = "::/0";
      #       Table = 233;
      #     }
      #   ];
      #   routingPolicyRules = [
      #     {
      #       FirewallMark = 1;
      #       Priority = 32762;
      #       Table = 233;
      #       Family = "both";
      #     }
      #   ];
      # };
    };
  };

  # resolved is conflict with dnsmasq
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = false;
    # resolve local queries (add 127.0.0.1 to /etc/resolv.conf)
    resolveLocalQueries = true; # may be conflict with dae, disable this.
    alwaysKeepRunning = true;
    # https://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=tree
    settings = {
      # upstream DNS servers
      server = builtins.attrValues nameservers;
      # forces dnsmasq to try each query with each server strictly
      # in the order they appear in the config.
      strict-order = true;

      # Never forward plain names (without a dot or domain part)
      domain-needed = true;
      # Never forward addresses in the non-routed address spaces(e.g. private IP).
      bogus-priv = true;
      # don't needlessly read /etc/resolv.conf which only contains the localhost addresses of dnsmasq itself.
      no-resolv = true;

      # Cache dns queries.
      cache-size = 1000;

      dhcp-range = [ "${dhcpRange.start},${dhcpRange.end},24h" ];
      interface = "br0";
      dhcp-sequential-ip = true;
      dhcp-option = [
        # Override the default route supplied by dnsmasq, which assumes the
        # router is the same machine as the one running dnsmasq.
        "option:router,${host}"
        "option:dns-server,${host}"
      ];

      # local domains
      local = "/lan/";
      domain = "lan";
      expand-hosts = true;

      # don't use /etc/hosts
      no-hosts = true;
      address = [
        # "/surfer.lan/192.168.10.1"
      ];
    };
  };
}
