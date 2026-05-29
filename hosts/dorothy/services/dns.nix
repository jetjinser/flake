{
  services.hickory-dns = {
    enable = true;
    settings = {
      listen_addrs_ipv4 = [
        "127.0.0.53"
      ];
      listen_addrs_ipv6 = [ ];
    };
    settings.zones = [
      {
        zone = "ts.net";
        zone_type = "External";
        stores = [
          {
            type = "forward";
            name_servers = [
              {
                ip = "100.100.100.100";
                trust_negative_responses = true;
                connections = [
                  {
                    port = 53;
                    protocol.type = "udp";
                  }
                ];
              }
            ];
            options = {
              timeout = 3;
              positive_max_ttl = 3600;
              negative_max_ttl = 3600;
              edns_payload_len = 1232;
            };
          }
        ];
      }
      {
        zone = ".";
        zone_type = "External";
        stores = [
          {
            type = "forward";
            name_servers = [
              {
                ip = "1.1.1.1";
                connections = [
                  {
                    protocol = {
                      type = "h3";
                      path = "/dns-query";
                      server_name = "cloudflare-dns.com";
                    };
                  }
                  {
                    protocol = {
                      type = "quic";
                      server_name = "cloudflare-dns.com";
                    };
                  }
                ];
              }
              # {
              #   ip = "223.5.5.5";
              #   connections = [
              #     {
              #       protocol = {
              #         type = "https";
              #         path = "/dns-query";
              #         server_name = "dns.alidns.com";
              #       };
              #     }
              #   ];
              # }
            ];
            options = {
              timeout = 3;
              num_concurrent_reqs = 4;
              positive_max_ttl = 3600;
              negative_max_ttl = 3600;
              edns_payload_len = 1232;
            };
          }
        ];
      }
    ];
  };

  networking = {
    nameservers = [
      "127.0.0.53"
    ];
    search = [
      "elk-agama.ts.net"
      # "home.arpa"
    ];
  };
}
