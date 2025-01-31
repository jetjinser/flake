{ lib
, config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "cosimo";
    nameservers = [ "223.5.5.5" "1.1.1.1" "9.9.9.9" ];
  };

  services.openssh.ports = lib.mkForce [ 2234 ];

  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    authKeyFile = secrets.tailscaleAuthKey.path;
    extraSetFlags = [ "--accept-dns=false" ];
  };
}
