let
  SSID = "⛩️";
  SSIDpassword = "qwertyui";
in

{
  networking = {
    firewall.enable = false;

    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
    };
  };
}
