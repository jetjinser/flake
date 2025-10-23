{
  flake,
  config,
  lib,
  ...
}:

let
  enable = false;

  inherit (config.sops) secrets;
  cfg = config.services;
in
{
  imports = [ flake.config.modules.nixos.services ];

  sops.secrets = lib.mkIf cfg.copilot-api.enable {
    gh-token = {
      owner = config.services.copilot-api.user;
      inherit (config.services.copilot-api) group;
      mode = "0400";
    };
  };
  services.copilot-api = {
    inherit enable;
    rateLimit = 30;
    githubTokenFile = secrets.gh-token.path;
  };
}
