{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking.hostName = "chabert";

  services.openssh.ports = lib.mkForce [ 2234 ];

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
