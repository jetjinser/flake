{
  config,
  ...
}:

let

  inherit (config.sops) secrets;
in
{
  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
