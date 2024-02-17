{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../hosts/cosimo/secrets.yaml;
    secrets = {
      tunnelJson = {
        owner = config.users.users.cloudflared.name;
      };

      plausiblePWD = { };
      plausibleSecretKeybase = { };

      yarrAuth = {
        owner = config.users.users.yarr.name;
      };
    };
  };
}
