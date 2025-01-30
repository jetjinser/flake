{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "chabert";
    nameservers = [
      "223.5.5.5"
      "1.1.1.1"
    ];
  };

  services.openssh.ports = lib.mkForce [ 2234 ];

  sops.secrets = {
    tailscaleAuthKey = { };
  };
  services.tailscale = {
    enable = false;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
