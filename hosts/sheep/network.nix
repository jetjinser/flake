# information from miecloud
{ config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "miecloud";

    useDHCP = false;

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.114.72";
        prefixLength = 21;
      }];
    };
    defaultGateway = {
      address = "192.168.113.254";
      interface = "ens18";
    };

    nameservers = [
      "119.29.29.29"
    ];
  };

  services.qemuGuest.enable = true;

  # ===
  sops.secrets = {
    tailscaleAuthKey = { };
  };

  services.tailscale = {
    enable = true;
    port = 27968;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
    useRoutingFeatures = "server";
    extraSetFlags = [ "--advertise-exit-node" ];
  };
}
