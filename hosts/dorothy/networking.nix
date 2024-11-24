{ config
, pkgs
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets.tailscaleAuthKey = { };
  services.tailscale = {
    enable = false;
    useRoutingFeatures = "client";
    authKeyFile = secrets.tailscaleAuthKey.path;
  };

  sops.secrets = {
    hometown-wifip = { };
    university-dormitory-wifip = { };
    mobile-hotspot-wifip = { };
  };
  sops.templates.nmenv.content = ''
    HOMETOWN_WIFI_PWD=${config.sops.placeholder.hometown-wifip}
    UNIVERSITY_DORMITORY_WIFI_PWD=${config.sops.placeholder.university-dormitory-wifip}
    MOBILE_HOTSPOT_WIFI_PWD=${config.sops.placeholder.mobile-hotspot-wifip}
  '';
  networking.networkmanager = {
    enable = true;
    dispatcherScripts = [{
      source = pkgs.writeShellScript "trigger-proxy" ''
        if [ "$DEVICE_IP_IFACE" != "wlp1s0" ]; then
          logger "exit: ignore iface $DEVICE_IP_IFACE"
          exit
        fi

        if [ "$NM_DISPATCHER_ACTION" == "up" ]; then
          systemctl stop sing-box.service
        fi
        if [ "$NM_DISPATCHER_ACTION" == "down" ]; then
          systemctl start sing-box.service
        fi
      '';
    }];
    # generated by https://github.com/Janik-Haag/nm2nix
    ensureProfiles = {
      environmentFiles = [ config.sops.templates.nmenv.path ];
      profiles = {
        hometown = {
          connection = {
            id = "hometown";
            interface-name = "wlp1s0";
            type = "wifi";
            uuid = "98091613-9c55-4698-ad40-b7d2528e95cc";
          };
          ipv4 = { method = "auto"; };
          ipv6 = { addr-gen-mode = "default"; method = "auto"; };
          proxy = { };
          wifi = { mode = "infrastructure"; ssid = "TP-LINK_6A59"; };
          wifi-security = { auth-alg = "open"; key-mgmt = "wpa-psk"; psk = "$HOMETOWN_WIFI_PWD"; };
        };
        university-dormitory = {
          connection = {
            id = "university-dormitory";
            interface-name = "wlp1s0";
            type = "wifi";
            uuid = "d83c8958-5019-4099-8d6b-7d8339612c6a";
          };
          ipv4 = { method = "manual"; address1 = "192.168.31.111/24,192.168.31.86"; dns = "1.1.1.1;"; };
          ipv6 = { addr-gen-mode = "default"; method = "auto"; };
          proxy = { };
          wifi = { mode = "infrastructure"; ssid = "abort_5G"; };
          wifi-security = { auth-alg = "open"; key-mgmt = "wpa-psk"; psk = "$UNIVERSITY_DORMITORY_WIFI_PWD"; };
        };
        mobile-hotspot = {
          connection = {
            id = "mobile-hotspot";
            interface-name = "wlp1s0";
            timestamp = "1724937443";
            type = "wifi";
            uuid = "dfa9fcd3-97a7-4ad8-adee-c40dd68d66c5";
          };
          ipv4 = { method = "auto"; };
          ipv6 = { addr-gen-mode = "default"; method = "auto"; };
          proxy = { };
          wifi = { mode = "infrastructure"; ssid = "xkcd"; };
          wifi-security = { auth-alg = "open"; key-mgmt = "wpa-psk"; psk = "$MOBILE_HOTSPOT_WIFI_PWD"; };
        };
      };
    };
  };

  networking.nftables.enable = true;
}
