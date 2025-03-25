{
  config,
  flake,
  lib,
  ...
}:

let
  cfg = config.services;

  enable = true;
in

# submodule
let
  fineTuningUser = {
    config = lib.mkIf enable {
      systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;

      systemd.services.open-webui.serviceConfig.DynamicUser = lib.mkForce false;
      systemd.services.open-webui.serviceConfig.User = "open-webui";
      systemd.services.open-webui.serviceConfig.Group = "open-webui";
      users = {
        users.open-webui = {
          home = cfg.open-webui.stateDir;
          isSystemUser = true;
          group = "open-webui";
        };
        groups.open-webui = { };
      };
    };
  };
in
{
  imports = [
    flake.config.modules.nixos.services
    fineTuningUser
  ];

  services.cloudflared' = lib.mkIf enable {
    ingress = {
      chat = cfg.open-webui.port;
    };
  };

  sops =
    let
      inherit (config.sops) placeholder;
    in
    {
      secrets = {
        DSToken = { };
        G_PSE_ENGINE_ID = { };
        G_PSE_API_KEY = { };
      };
      templates."open-webui.env".content = ''
        GOOGLE_PSE_ENGINE_ID = "${placeholder.G_PSE_ENGINE_ID}"
        GOOGLE_PSE_API_KEY = "${placeholder.G_PSE_API_KEY}"

        OPENAI_API_KEY = "${placeholder.DSToken}"
      '';
    };

  services = {
    ollama = {
      inherit enable;
      user = "ollama";
      loadModels = [
        "deepseek-r1:14b"
        "gemma3:12b"
      ];
    };
    open-webui = {
      inherit (cfg.ollama) enable;
      port = 9000;
      environmentFile = config.sops.templates."open-webui.env".path;
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "True";

        RAG_WEB_SEARCH_TRUST_ENV = "True";
        HTTP_PROXY = "http://192.168.114.1:8080/";
        HTTPS_PROXY = "http://192.168.114.1:8080/";
        NO_PROXY = "127.0.0.1,localhost";

        ENABLE_OPENAI_API = "True";
        OPENAI_API_BASE_URL = "https://api.deepseek.com";

        OLLAMA_API_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";

        ENABLE_RAG_WEB_SEARCH = "True";
        RAG_WEB_SEARCH_RESULT_COUNT = "5";
        RAG_WEB_SEARCH_ENGINE = "google_pse";
      };
    };
  };

  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
