{ config
, ...
}:

let
  cfg = config.services;
in
{
  services = {
    ollama = {
      enable = true;
      loadModels = [
        # "deepseek-r1:1.5b"
        "deepseek-r1:7b"
      ];
    };
    open-webui = {
      enable = true;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";

        http_proxy = "http://127.0.0.1:7890/";
        https_proxy = "http://127.0.0.1:7890/";

        ENABLE_OPENAI_API = "False";
        OLLAMA_API_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
      };
    };
  };
  # preservation.preserveAt."/persist" = {
  #   directories = [ cfg.ollama.home cfg.open-webui.stateDir ];
  # };
  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
