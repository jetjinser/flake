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

  services.cloudflared' = {
    ingress = {
      chat = cfg.open-webui.port;
    };
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
      environment = {
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        WEBUI_AUTH = "True";

        http_proxy = "http://192.168.114.1:8080/";
        https_proxy = "http://192.168.114.1:8080/";
        no_proxy = "127.0.0.1,localhost";

        ENABLE_OPENAI_API = "False";
        OLLAMA_API_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
      };
    };
  };

  preservation.preserveAt."/persist" = {
    directories =
      (lib.optional cfg.ollama.enable cfg.ollama.home)
      ++ (lib.optional cfg.open-webui.enable cfg.open-webui.stateDir);
  };
  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
