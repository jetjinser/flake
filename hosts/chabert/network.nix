{
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "chabert";
    nameservers = [
      "223.5.5.5"
      "1.1.1.1"
      "9.9.9.9"
    ];
    useNetworkd = true;
  };

  services.openssh.ports = lib.mkForce [ 2234 ];

  sops.secrets = {
    tailscaleAuthKey = { };
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
  preservation.preserveAt."/persist" = lib.mkIf cfg.tailscale.enable {
    directories = [ "/var/lib/tailscale" ];
  };
}
