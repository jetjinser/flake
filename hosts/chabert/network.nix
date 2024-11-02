{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    tailscaleAuthKey = { };
  };

  networking.hostName = "chabert";

  services.openssh.ports = lib.mkForce [ 2234 ];

  services.tailscale = {
    enable = false;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
