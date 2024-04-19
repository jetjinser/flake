# https://github.com/ryan4yin/nix-config/blob/7fd3baca0f651a5b9b1438f4e74620f59716d5bf/hosts/12kingdoms-suzu/microvm/suzi/networking.nix

{ lib
, flake
, ...
}:

let
  inherit (flake.config.symbols.nanopi-r2s) host;

  mainGateway = "192.168.31.1";
  nameservers = [
    "119.29.29.29" # DNSPod
    "223.5.5.5" # AliDNS
  ];

  ipv4WithMask = "${host}/24";
  dhcpRange = {
    start = "192.168.31.31";
    end = "192.168.31.85";
  };
in
{
  boot.kernelModules = [
    "tcp_bbr"
    # preload to make sysctl options avaliable
    "nf_conntrack"
  ];
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    # "net.ipv6.conf.all.forwarding" = true;
    "net.ipv4.conf.br-lan.rp_filter" = 1;
    "net.ipv4.conf.br-lan.send_redirects" = 0;
  };

  # required to set hostname, see <https://github.com/systemd/systemd/issues/16656>
  security.polkit.enable = true;

  virtualisation.docker.enable = lib.mkForce false;
  networking = {
    hostName = "barnabas";

    useNetworkd = true;

    useDHCP = false;
    networkmanager.enable = false;
    wireless.enable = false; # Enables wireless support via wpa_supplicant.
    # No local firewall.
    nat.enable = false;
    firewall.enable = false;

    nftables = {
      # TODO: enable when ready
      enable = false;
      ruleset = ''
        table ip filter {
          chain input {
            type filter hook input priority 0;

            # accept any localhost traffic
            iifname lo accept

            # accept any lan traffic
            iifname br-lan accept

            # count and drop any other traffic
            counter drop
          }

          # Allow all outgoing connections.
          chain output {
            type filter hook output priority 0;
            accept
          }

          # Allow all forwarding all traffic.
          chain forward {
            type filter hook forward priority 0;
            accept
          }
        }
      '';
    };
  };

  systemd.network = {
    enable = true;
    netdevs = {
      # Create the bridge interface
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = "br-lan";
        };
      };
    };
    # This is a bypass router, so we do not need a wan interface here.
    networks = {
      "30-lan0" = {
        # match the interface by type
        matchConfig.Type = "ether";
        # Connect to the bridge
        networkConfig = {
          Bridge = "br-lan";
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };
      # Configure the bridge device we just created
      "40-br-lan" = {
        matchConfig.Name = "br-lan";
        address = [
          # configure addresses including subnet mask
          ipv4WithMask # forwards all traffic to the gateway except for the router address itself
        ];
        routes = [
          # forward all traffic to the main gateway
          { routeConfig.Gateway = mainGateway; }
        ];
        bridgeConfig = { };
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  # resolved is conflict with dnsmasq
  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;
    # resolve local queries (add 127.0.0.1 to /etc/resolv.conf)
    resolveLocalQueries = true; # may be conflict with dae, disable this.
    alwaysKeepRunning = true;
    # https://thekelleys.org.uk/gitweb/?p=dnsmasq.git;a=tree
    settings = {
      # upstream DNS servers
      server = nameservers;
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
      interface = "br-lan";
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
