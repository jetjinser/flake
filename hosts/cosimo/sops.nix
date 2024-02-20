{ config, ... }:

let
  inherit (config.users) users;
in
{
  sops = {
    defaultSopsFile = ../../hosts/cosimo/secrets.yaml;
    secrets = {
      IcuTunnelJson = {
        owner = users.cloudflared.name;
      };
      OrgTunnelJson = {
        owner = users.cloudflared.name;
      };

      plausiblePWD = { };
      plausibleSecretKeybase = { };

      yarrAuth = {
        owner = users.yarr.name;
      };

      jinserMailPWD = { };
      noreplyMailPWD = { };

      sendgridApiKey = {
        owner = users.forgejo.name;
      };
      qcloudmailPWD = {
        owner = users.forgejo.name;
      };
    };
  };
}
