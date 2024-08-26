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
      };
    };
  };

  sops = {
    secrets.hometown-wifip = { };
    templates.nmenv.content = ''
      HOMETOWN_WIFI_PWD=${config.sops.placeholder.hometown-wifip}
    '';
  };
}
