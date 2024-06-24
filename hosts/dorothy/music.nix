{ config
, pkgs
, ...
}:

let
  inherit (config.sops) secrets;
  systemd-user = "spotifyd";
in
{
  environment.systemPackages = [
    pkgs.spotify-player
  ];

  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username_cmd = "cat ${secrets.spotify_username.path}";
        password_cmd = "cat ${secrets.spotify_password.path}";
        backend = "pulseaudio";
        device_name = config.networking.hostName;
        bitrate = 320;
        no_audio_cache = false;
      };
    };
  };

  systemd.services.spotifyd.serviceConfig.User = systemd-user;
  systemd.services.spotifyd.serviceConfig.Group = systemd-user;

  users.users = {
    ${systemd-user} = {
      group = systemd-user;
      isSystemUser = true;
    };
  };
  users.groups = {
    ${systemd-user} = { };
  };
}
