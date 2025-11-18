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
    openFirewall = true;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--relay-server-port=27968" ];
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
  networking.firewall.allowedUDPPorts = [ 27968 ];
}
