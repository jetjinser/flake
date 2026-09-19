{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.services.hickory-dns;
in
{
  environment.systemPackages = [ pkgs.bind ];

  services.hickory-dns = {
    enable = true;
    quiet = true;
    settings = {
      listen_addrs_ipv4 = [ "127.0.0.53" ];
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
                    port = 443;
                    protocol = {
                      type = "https";
                      path = "/dns-query";
                      server_name = "1.1.1.1";
                    };
                  }
                ];
              }
              {
                ip = "223.5.5.5";
                connections = [
                  {
                    port = 443;
                    protocol = {
                      type = "https";
                      path = "/dns-query";
                      server_name = "223.5.5.5";
                    };
                  }
                ];
              }
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

  networking = lib.mkIf cfg.enable {
    nameservers = [ "127.0.0.53" ];
    search = [
      "elk-agama.ts.net"
      # "home.arpa"
    ];
  };
}
