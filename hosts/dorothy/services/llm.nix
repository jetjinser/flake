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
        "everythinglm:13b"
        "huihui_ai/jan-nano-abliterated:4b"
        "llama3.2:latest"
        # keep-sorted end
      ];
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
