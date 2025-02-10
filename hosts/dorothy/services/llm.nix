{
  config,
  flake,
  lib,
  ...
}:

let
  inherit (config.sops) secrets;
  inherit (config.users) users;

  cfg = config.services;

  enable = false;
  publicChat = enable && false;

  purejs = "purejs.icu";
  cdTunnelID = "chez-dorothy";
in
{
  imports = [ flake.config.modules.nixos.services ];

  sops.secrets = lib.mkIf cfg.cloudflared'.enable {
    cdTunnelJson.owner = users.cloudflared.name;
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    enable = publicChat && cfg.open-webui.enable;
    tunnelID = cdTunnelID;
    domain = purejs;
    credentialsFile = secrets.cdTunnelJson.path;
    originCert = secrets.originCert.path;
    ingress = {
      chat = cfg.open-webui.port;
    };
  };

  services = {
    ollama = {
      inherit enable;
      user = "ollama";
      loadModels = [
        "deepseek-r1:1.5b"
        "deepseek-r1:7b"
        "mistral-small:24b"
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

        http_proxy = "http://127.0.0.1:7890/";
        https_proxy = "http://127.0.0.1:7890/";

        ENABLE_OPENAI_API = "False";
        OLLAMA_API_BASE_URL = "http://${cfg.ollama.host}:${toString cfg.ollama.port}";
      };
    };
  };

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

  preservation.preserveAt."/persist" = {
    directories = [
      cfg.ollama.home
      cfg.open-webui.stateDir
    ];
  };
  # broken: https://github.com/NixOS/nixpkgs/pull/367695
  # nixpkgs.config = {
  #   cudaSupport = false;
  #   rocmSupport = true;
  # };
}
