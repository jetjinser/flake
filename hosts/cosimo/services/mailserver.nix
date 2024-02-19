{ config, ... }:

let
  inherit (config.sops) secrets;
in
{
  mailserver = {
    # wait to set rdns
    enable = true;
    fqdn = "mail.yeufossa.org";
    domains = [ "yeufossa.org" ];

    loginAccounts = {
      "jinser@yeufossa.org" = {
        hashedPasswordFile = secrets.jinserMailPWD.path;
        aliases = [ "admin@yeufossa.org" ];
      };
      "noreply@yeufossa.org" = {
        hashedPasswordFile = secrets.noreplyMailPWD.path;
      };
    };

    # Use Let's Encrypt certificates.
    # Note that this needs to set up a stripped down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
  security = {
    acme.acceptTerms = true;
    acme.defaults.email = "security@yeufossa.org";
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
