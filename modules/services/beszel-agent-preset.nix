{
  flake,
  config,
  lib,
  ...
}:

let
  hub-cfg = flake.self.nixosConfigurations.sheep.config.services.beszel.hub;
  cfg = config.services.beszel-agent-preset;
in
{
  options.services.beszel-agent-preset = {
    enable = lib.mkEnableOption "Enable the beszel agent (preset) service.";

    tokenPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to token.";
    };
    hubUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://${hub-cfg.host}:${toString hub-cfg.port}";
    };
    key = lib.mkOption {
      type = lib.types.str;
    };

    agentEnv = lib.mkOption {
      type = lib.types.attrs;
      default = {
        LOG_LEVEL = "warn";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.beszel.agent = {
      enable = true;
      environment = {
        HUB_URL = cfg.hubUrl;
        KEY = cfg.key;
        # TOKEN_FILE = "$CREDENTIALS_DIRECTORY/hubToken";
        TOKEN_FILE = "/run/credentials/beszel-agent.service/hubToken";
      }
      // cfg.agentEnv;
    };

    systemd.services.beszel-agent.serviceConfig.LoadCredential = "hubToken:${cfg.tokenPath}";
  };
}
