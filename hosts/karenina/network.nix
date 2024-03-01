let
  SSID = "⛩️";
  SSIDpassword = "qwertyui";
  hostName = "karenina";
in

{
  networking = {
    inherit hostName;

    networkmanager = {
      enable = true;
      ensureProfiles = {
        profiles = {
          dormitory-wifi = {
            connection = {
              id = "dormitory-wifi";
              permissions = "";
              type = "wifi";
            };
            ipv4.method = "auto";
            ipv6.method = "auto";
            wifi = {
              ssid = SSID;
              mode = "infrastructure";
              password = SSIDpassword;
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
            };
          };
        };
      };
    };
    wireless.enable = false;
  };
}
