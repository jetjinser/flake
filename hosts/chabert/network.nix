{ config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking.hostName = "chabert";

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
