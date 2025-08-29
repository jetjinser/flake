{
  pkgs,
  lib,
  config,
  ...
}:

let
  enable = true;
  inherit (config.sops) secrets;
in
{
  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.local = {
      inherit enable;
      url = config.services.forgejo.settings.server.ROOT_URL;
      tokenFile = secrets.runnerToken.path;
      name = config.networking.hostName;
      labels = [ "native:host" ];
      hostPackages = lib.mkOptionDefault (
        lib.mkBefore (
          with pkgs;
          [
            # keep-sorted start
            nushell
            python3
            scsh
            zuo
            # keep-sorted end
          ]
        )
      );
    };
  };

  sops.secrets = {
    runnerToken = { };
  };
}
