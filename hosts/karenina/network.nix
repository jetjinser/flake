{
  config,
  ...
}:

let
  inherit (config.sops) secrets;
in
{
  # https://wiki.nixos.org/wiki/Systemd-networkd

  sops = {
    secrets.abort_psk = { };
    templates."wireless.conf".content = ''
      abort_psk="${config.sops.placeholder.abort_psk}"
    '';
  };
  networking = {
    # this option in addition to enabling systemd-networkd,
    # also offers translation of some networking.interfaces
    # and networking.useDHCP options into networkd
    useNetworkd = true;
    dhcpcd.enable = false;

    wireless = {
      enable = true;
      secretsFile = config.sops.templates."wireless.conf".path;
      interfaces = [ "wlan0" ];
      networks = {
        "abort".psk = "ext:abort_psk";
      };
    };
  };

  networking.hostName = "karenina";
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

  systemd.network = {
    enable = true;

    networks."10-wlan" = {
      matchConfig.Name = "wlan0";
      address = [
        "192.168.31.121/24"
      ];
      routes = [
        { Gateway = "192.168.31.1"; }
      ];
      dns = [
        "1.1.1.1"
        "119.29.29.29"
      ];
      # make the routes on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
      # resovle nss
      networkConfig.MulticastDNS = "resolve";
    };

    networks."20-end" = {
      matchConfig.Name = "end0";
      address = [
        "192.168.31.120/24"
      ];
      routes = [
        { Gateway = "192.168.31.1"; }
      ];
      dns = [
        "1.1.1.1"
        "119.29.29.29"
      ];
      # make the routes on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
      # resovle nss
      networkConfig.MulticastDNS = "resolve";
    };
  };

  sops.secrets = {
    tailscaleAuthKey = { };
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
