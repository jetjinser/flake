{
  config,
  ...
}:

let

  inherit (config.sops) secrets;
in
{
  networking = {
    hostName = "bendemann";
    nameservers = [
      "223.5.5.5"
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
