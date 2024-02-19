{ config, lib, ... }:

let
  enable = false;

  inherit (config.sops) secrets;
in
{
  mailserver = {
    inherit enable;
    enableImap = true;
    enableImapSsl = true;

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

  services.dovecot2.sieve.extensions = lib.mkIf enable [ "fileinto" ];

  networking = lib.mkIf enable {
    firewall.allowedTCPPorts = [
      443
    ];
    nameservers = lib.mkForce [ "1.1.1.1" "9.9.9.9" "119.29.29.29" ];
  };
}
