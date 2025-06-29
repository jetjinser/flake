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
        "llama3.2:latest"
        "devstral:24b"
        "deepseek-r1:7b"
        "mistral-small:24b"
        "deepseek-r1:1.5b"
      ];
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
