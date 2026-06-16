{
  pkgs,
  lib,
  config,
  ...
}:

let
  enable = true;

  cfg = config.services;
  karakeep-port = 8008;

  proxy = config.networking.proxy.default;
  no_proxy = "localhost,127.0.0.1,.local,.ts.net";
in
{
  sops =
    let
      inherit (config.sops) placeholder;
      owner = config.systemd.services.karakeep-workers.serviceConfig.User;
    in
    lib.mkIf enable {
      secrets.bifrost_api_key = { };
      templates = {
        "karakeep-secrets.env" = {
          content = # env
            ''
              OPENAI_API_KEY="${placeholder.bifrost_api_key}"
            '';
          inherit owner;
        };
      };
    };

  services.karakeep = {
    inherit enable;
    browser = {
      enable = true;
      exe = lib.getExe pkgs.ungoogled-chromium;
    };
    meilisearch.enable = true;
    environmentFile = config.sops.templates."karakeep-secrets.env".path;
    extraEnvironment = {
      PORT = toString karakeep-port;
      DISABLE_SIGNUPS = "true";
      DISABLE_NEW_RELEASE_CHECK = "true";
      LOG_LEVEL = "warn";
      DB_WAL_MODE = "true";

      SEARCH_NUM_WORKERS = "2";
      CRAWLER_FULL_PAGE_ARCHIVE = "true";
      CRAWLER_VIDEO_DOWNLOAD = "false";
      CRAWLER_VIDEO_DOWNLOAD_MAX_SIZE = "-1";

      CRAWLER_HTTP_PROXY = proxy;
      CRAWLER_HTTPS_PROXY = proxy;
      CRAWLER_NO_PROXY = no_proxy;

      OPENAI_BASE_URL = "https://ai.estin.space/openai";
      INFERENCE_TEXT_MODEL = "mimo/mimo-v2.5-pro";
      INFERENCE_IMAGE_MODEL = "mimo/mimo-v2.5";
      INFERENCE_LANG = "chinese";
      INFERENCE_ENABLE_AUTO_TAGGING = "true";
      INFERENCE_ENABLE_AUTO_SUMMARIZATION = "true";

      OCR_LANGS = "eng,chi_sim,chi_tra";
    }
    // (lib.optionalAttrs cfg.ollama.enable {
      OLLAMA_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
      EMBEDDING_TEXT_MODEL = "dengcao/Qwen3-Embedding-4B:Q4_K_M";
    });
  };
  systemd.services.karakeep-browser = {
    environment = {
      ALL_PROXY = proxy;
      HTTP_PROXY = proxy;
      HTTPS_PROXY = proxy;
      NO_PROXY = no_proxy;
    };
    script = ''
      export HOME="$CACHE_DIRECTORY"
      exec ${cfg.karakeep.browser.exe} \
        --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
        --remote-debugging-address=127.0.0.1 \
        --remote-debugging-port=${toString cfg.karakeep.browser.port} \
        --hide-scrollbars \
        --user-data-dir="$STATE_DIRECTORY" \
        --proxy-auto-detect
    '';
  };

  services.caddy.virtualHosts = lib.mkIf cfg.karakeep.enable {
    "k.2jk.pw" = {
      extraConfig = ''
        import tsnet
        reverse_proxy http://127.0.0.1:${cfg.karakeep.extraEnvironment.PORT} {
          header_down X-Real-IP {http.request.remote}
          header_down X-Forwarded-For {http.request.remote}
        }
      '';
    };
  };

  # services.cloudflared'.ingress = {
  #   kk = karakeep-port;
  # };
}
