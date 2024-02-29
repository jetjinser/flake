let
  SSID = "⛩️";
  SSIDpassword = "qwertyui";
in

{
  networking = {
    wireless = {
      enable = true;
      networks."${SSID}".psk = SSIDpassword;
    };
  };
}
