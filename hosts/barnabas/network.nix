{ config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
