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
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
