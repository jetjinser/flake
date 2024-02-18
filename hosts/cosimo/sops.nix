{ config, ... }:

{
  sops = {
    defaultSopsFile = ../../hosts/cosimo/secrets.yaml;
    secrets = {
      IcuTunnelJson = {
        owner = config.users.users.cloudflared.name;
      };
      OrgTunnelJson = {
        owner = config.users.users.cloudflared.name;
      };

      plausiblePWD = { };
      plausibleSecretKeybase = { };

      yarrAuth = {
        owner = config.users.users.yarr.name;
      };

      jinserMailPWD = { };
      noreplyMailPWD = { };
    };
  };
}
