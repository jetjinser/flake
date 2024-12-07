{ config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    tailscaleAuthKey = { };
  };
  services.tailscale = {
    enable = false;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
