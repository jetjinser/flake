{
  config,
  flake,
  lib,
  ...
}:

let
  cfg = config.services;
  domain = config.services.cloudflared'.domain;

  enable = true;

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
    flake.config.modules.nixos.misc
    fineTuningUser
  ];

  services.cloudflared' = lib.mkIf enable {
    ingress = {
      chat = cfg.open-webui.port;
      n8n = cfg.n8n.settings.port;
    };
  };
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "agent-ghost" ];
    ensureUsers = [
      {
        name = "agent-ghost";
        ensureDBOwnership = true;
      }
    ];
    authentication = ''
      local agent-ghost agent-ghost trust
    '';
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
        "qwen3:0.6b"
        "qwen3:1.7b"
        "qwen3:8b"
        "mxbai-embed-large:latest"
        "llama3.2:3b"
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
    qdrant = {
      inherit (cfg.ollama) enable;
      settings = {
        storage = {
          storage_path = "/var/lib/qdrant/storage";
          snapshots_path = "/var/lib/qdrant/snapshots";
        };
        hsnw_index = {
          on_disk = true;
        };
        service = {
          host = "127.0.0.1";
          http_port = 9001;
          grpc_port = 9002;
        };
        telemetry_disabled = true;
      };
    };
    n8n = {
      inherit (cfg.ollama) enable;
      webhookUrl = "${cfg.n8n.settings.protocol}://${cfg.n8n.settings.host}";
      settings = {
        host = "n8n.${domain}";
        port = 5678; # cannot change?
        protocol = "https";
        hiringBanner.enabled = false;
        generic.timezone = config.time.timeZone;
        logging.level = "warn";

        # disable telemetry
        diagnostics = {
          enabled = false;
          frontendConfig = "";
          backendConfig = "";
        };
        versionNotifications.enabled = false;
        templates.enabled = false;
      };
    };
  };
  # TODO: replace those unfree
  nixpkgs.superConfig.allowUnfreeList = lib.mkIf cfg.open-webui.enable [
    "open-webui" # with librechat or ...
    "n8n" # with node-red or kestra or ...
  ];

  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
