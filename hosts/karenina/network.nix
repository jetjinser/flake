{ config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  # https://nixos.wiki/wiki/Systemd-networkd

  networking = {
    hostName = "karenina";

    # this option in addition to enabling systemd-networkd,
    # also offers translation of some networking.interfaces
    # and networking.useDHCP options into networkd
    useNetworkd = true;
    dhcpcd.enable = false;

    wireless = {
      enable = true;
      interfaces = [ "wlan0" ];
      networks = {
        "⛩️_5G" = {
          psk = "qwertyui";
        };
      };
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
        { routeConfig.Gateway = "192.168.31.1"; }
      ];
      dns = [
        "1.1.1.1"
        "119.29.29.29"
      ];
      # make the routes on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
    };

    networks."20-end" = {
      matchConfig.Name = "end0";
      address = [
        "192.168.31.120/24"
      ];
      routes = [
        { routeConfig.Gateway = "192.168.31.1"; }
      ];
      dns = [
        "1.1.1.1"
        "119.29.29.29"
      ];
      # make the routes on this interface a dependency for network-online.target
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = secrets.tailscaleAuthKey.path;
  };
}
