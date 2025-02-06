{
  lib,
  config,
  ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "cosimo";
    nameservers = [
      "223.5.5.5"
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.openssh.ports = lib.mkForce [ 2234 ];

  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    openFirewall = true; # default port: 41641
    useRoutingFeatures = "server";
    extraSetFlags = [ "--webclient" ];
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
