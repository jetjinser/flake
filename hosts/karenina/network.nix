{ lib, ... }:

let
  SSID = "⛩️";
  SSIDpassword = "qwertyui";
in

{
  networking = {
    useDHCP = true;
    useNetworkd = true;
    firewall.enable = lib.mkForce false;

    wireless = {
      enable = true;
      fallbackToWPA2 = false;
      networks = {
        "${SSID}".psk = SSIDpassword;
        "xkcd".psk = "qqrtqrqoqoiqp";
      };
    };
  };
}
