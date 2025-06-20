# information from miecloud
{
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "miecloud";

    useDHCP = false;

    interfaces = {
      ens18.ipv4.addresses = [
        {
          address = "192.168.114.72";
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = {
      address = "192.168.114.254";
      interface = "ens18";
    };

    nameservers = [
      "119.29.29.29"
    ];
  };

  services.qemuGuest.enable = true;

  # ===
  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    port = 27968; # udp
    openFirewall = true;
    useRoutingFeatures = "server";
    extraUpFlags = [ "--reset" ];
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
  networking.firewall.allowedTCPPorts = [ 27968 ];
  preservation.preserveAt."/persist" = lib.mkIf cfg.tailscale.enable {
    directories = [ "/var/lib/tailscale" ];
  };
}
