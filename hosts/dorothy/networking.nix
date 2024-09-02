{ config
, ...
}:

{
  networking.networkmanager = {
    enable = true;
    ensureProfiles = {
      environmentFiles = [ config.sops.templates.nmenv.path ];
      profiles = {
        hometown = {
          connection = {
            id = "TP-LINK_6A59";
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
            id = "abort_5G";
            interface-name = "wlp1s0";
            type = "wifi";
            uuid = "d83c8958-5019-4099-8d6b-7d8339612c6a";
          };
          ipv4 = { method = "auto"; };
          ipv6 = { addr-gen-mode = "default"; method = "auto"; };
          proxy = { };
          wifi = { mode = "infrastructure"; ssid = "abort_5G"; };
          wifi-security = { auth-alg = "open"; key-mgmt = "wpa-psk"; psk = "$UNIVERSITY_DORMITORY_WIFI_PWD"; };
        };
        mobile-hotspot = {
          connection = {
            id = "xkcd";
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

  sops = {
    secrets = {
      hometown-wifip = { };
      university-dormitory-wifip = { };
      mobile-hotspot-wifip = { };
    };
    templates.nmenv.content = ''
      HOMETOWN_WIFI_PWD=${config.sops.placeholder.hometown-wifip}
      UNIVERSITY_DORMITORY_WIFI_PWD=${config.sops.placeholder.university-dormitory-wifip}
      MOBILE_HOTSPOT_WIFI_PWD=${config.sops.placeholder.mobile-hotspot-wifip}
    '';
  };
}
