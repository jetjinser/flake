{
  config,
  ...
}:

let
  enable = false;
in
{
  services = {
    spotifyd = {
      inherit enable;
      settings = {
        global = {
          device_name = "${config.networking.hostName}.spotifyd";
          dbus_type = "system";
          use_mpris = true;
          bitrate = 320;
          initial_volume = 30;
          zeroconf_port = 18089;
        };
      };
    };
  };
}
