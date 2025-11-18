{
  lib,
  config,
  pkgs,
  ...
}:

let
  enable = true;

  inherit (config.sops) secrets;
  inherit (config.networking) hostName;
  cfg = config.services.librechat;
  mgdbCfg = config.services.mongodb;
  msCfg = config.services.meilisearch;
  olCfg = config.services.ollama;
in

{
  services.librechat = {
    inherit enable;
    port = 19000;
    env = {
      ALLOW_REGISTRATION = "true";
      ALLOW_SOCIAL_LOGIN = "false";
      HOST = hostName;
      MONGO_URI = "mongodb://${mgdbCfg.bind_ip}/LibreChat";
      CUSTOM_FOOTER = "Hosted by BHU";
      DOMAIN_CLIENT = "https://chat.bhu.social";
      DOMAIN_SERVER = "https://chat.bhu.social";

      SEARCH = "true";
      MEILI_NO_ANALYTICS = "true";
      MEILI_HOST = "http://${msCfg.listenAddress}:${toString msCfg.listenPort}";
      MEILI_MASTER_KEY = "dummy";

      # https://github.com/danny-avila/rag_api
      # RAG_API_URL = "http://${olCfg.host}:${toString olCfg.port}";
      EMBEDDINGS_PROVIDER = "ollama";
      OLLAMA_BASE_URL = "http://${olCfg.host}:${toString olCfg.port}";
      EMBEDDINGS_MODEL = "embeddinggemma:300m";
    };
    credentials = {
      CREDS_KEY = secrets.creds_key.path;
      CREDS_IV = secrets.creds_iv.path;
      JWT_SECRET = secrets.jwt_secret.path;
      JWT_REFRESH_SECRET = secrets.jwt_refresh_secret.path;
      kimiToken = secrets.kimiToken.path;
      dpskToken = secrets.dpskToken.path;
      G_PSE_ENGINE_ID = secrets.G_PSE_ENGINE_ID.path;
      G_PSE_API_KEY = secrets.G_PSE_API_KEY.path;
    };
    settings = {
      version = "1.2.5";
      cache = true;
      endpoints = {
        custom = [
          {
            name = "Kimi";
            apiKey = "\${kimiToken}";
            baseURL = "https://api.moonshot.cn/v1";
            models = {
              default = [ "kimi-k2-turbo-preview" ];
              fetch = true;
            };
            titleConvo = true;
            titleModel = "current_model";
            modelDisplayLabel = "Kimi";
          }
          {
            name = "Deepseek";
            apiKey = "\${dpskToken}";
            baseURL = "https://api.deepseek.com/v1";
            models = {
              default = [
                "deepseek-chat"
                "deepseek-coder"
                "deepseek-reasoner"
              ];
              fetch = false;
            };
            titleConvo = true;
            titleModel = "current_model";
            modelDisplayLabel = "Deepseek";
          }
        ];
      };
      # added in 1.2.6
      # webSearch = {
      #   searchProvider = "searxng";
      #   searxngInstanceUrl = "https://search.bhu.social";
      # };
    };
  };

  sops.secrets = lib.mkIf cfg.enable (
    lib.genAttrs
      [
        "creds_key"
        "creds_iv"
        "jwt_secret"
        "jwt_refresh_secret"
        "meili_master_key"
        "meili_master_key"
        "kimiToken"
        "dpskToken"
        "G_PSE_ENGINE_ID"
        "G_PSE_API_KEY"
      ]
      (_: {
        owner = cfg.user;
        inherit (cfg) group;
      })
  );

  nixpkgs.superConfig.allowUnfreeList = [ "mongodb-ce" ]; # sspl
  services.mongodb = {
    inherit (cfg) enable;
    package = pkgs.mongodb-ce;
  };

  services.meilisearch = {
    inherit (cfg) enable;
  };
  services.ollama = {
    inherit (cfg) enable;
    loadModels = [
      "embeddinggemma:300m"
    ];
  };

  services.caddy.virtualHosts = lib.mkIf cfg.enable {
    "chat.bhu.social".extraConfig = ''
      import tsnet
      reverse_proxy http://${cfg.env.HOST}:${toString cfg.port} {
        header_down X-Real-IP {http.request.remote}
        header_down X-Forwarded-For {http.request.remote}
      }
    '';
  };
}
