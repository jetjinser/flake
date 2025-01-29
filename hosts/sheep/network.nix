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
    useDHCP = true;
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
