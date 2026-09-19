{
  config,
  lib,
  flake,
  ...
}:

let
  cfg = config.services;
  enable = true;

  inherit (flake.config.symbols.people) myself;

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
    agentsview = {
      enable = false;
      offline = true;
      user = myself;
      home = "/home/${myself}";
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [ cfg.ollama.home ];
  };
}
