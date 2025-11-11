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
        # keep-sorted start
        "llama3.2:latest"
        "devstral:24b"
        "deepseek-r1:7b"
        "mistral-small:24b"
        "deepseek-r1:1.5b"
        "qwen3:8b"
        # keep-sorted end
      ];
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
