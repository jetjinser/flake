{
  config,
  lib,
  ...
}:

let
  cfg = config.services;
  enable = true;

  fineTuningUser = {
    config = lib.mkIf enable {
      systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
    };
  };
in
{
  imports = [ fineTuningUser ];

  services = {
    ollama = {
      inherit enable;
      user = "ollama";
      loadModels = [
        "devstral:24b"
        "llama3.2:latest"
      ];
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
