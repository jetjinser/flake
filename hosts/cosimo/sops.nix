{
  flake,
  ...
}:

{
  imports = [
    flake.inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      # jinserMailPWD = { };
      # noreplyMailPWD = { };

      # sendgridApiKey = {
      #   mode = "0440";
      #   group = groups.mailer.name;
      # };
      # qcloudmailPWD = {
      #   mode = "0440";
      #   group = groups.mailer.name;
      # };
    };
  };
}
