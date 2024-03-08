{ config, ... }:

let
  inherit (config.users) users groups;
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
        mode = "0440";
        group = groups.mailer.name;
      };
      qcloudmailPWD = {
        mode = "0440";
        group = groups.mailer.name;
      };

      passwordSalt = {
        owner = users.wakapi.name;
      };

      alistPWD = {
        owner = users.alist.name;
      };
      alistJWTSecret = {
        owner = users.alist.name;
      };

      # resticPWD = {
      #   owner = users.restic.name;
      # };
      # rcloneConf = {
      #   owner = users.restic.name;
      # };
    };
  };
}
