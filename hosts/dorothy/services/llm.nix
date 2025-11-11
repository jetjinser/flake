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
        "deepseek-r1:1.5b"
        "deepseek-r1:7b"
        "devstral:24b"
        "llama3.2:latest"
        "mistral-small:24b"
        "qwen3:8b"
        # keep-sorted end
      ];
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
