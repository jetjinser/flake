{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.services.agentsview;
in
{
  options.services.agentsview = {
    enable = lib.mkEnableOption "AgentsView service for AI coding agent analytics";

    package = lib.mkOption {
      type = lib.types.package;
      default = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.agentsview;
      description = "The agentsview package to use.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4090;
      description = "Port on which AgentsView web UI will listen.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address to bind the service to.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "agentsview";
      description = "User account under which AgentsView runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "agentsview";
      description = "Group under which AgentsView runs.";
    };

    home = lib.mkOption {
      type = lib.types.path;
      description = "Directory to HOME AgentsView will detect.";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/agentsview";
      description = "Directory to store AgentsView SQLite DB and state.";
    };

    targetUserHome = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        The home directory of the user whose AI agent sessions should be analyzed.
        If set, agent log directories will automatically default to paths inside this directory.
      '';
      example = "/home/alice";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables passed to the AgentsView service.";
      example = lib.literalExpression ''
        {
          DEVIN_DIR = "/home/alice/.local/share/devin";
          COPILOT_DIR = "/home/alice/.copilot";
        }
      '';
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra command line flags passed to `agentsview serve`.";
      example = [
        "--public-url"
        "http://127.0.0.1:8080"
      ];
    };

    offline = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Completely block outbound network access, allowing local UI access only.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${cfg.user} = lib.mkIf (cfg.user == "agentsview") {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
      createHome = true;
      description = "AgentsView Service User";
    };

    users.groups.${cfg.group} = lib.mkIf (cfg.group == "agentsview") { };

    systemd.services.agentsview = {
      description = "AgentsView - Local-first AI agent search & analytics";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = cfg.home;
        AGENTSVIEW_DATA_DIR = cfg.dataDir;
      }
      // cfg.env;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = cfg.dataDir;
        StateDirectory = "agentsview";

        ExecStart = "${cfg.package}/bin/agentsview serve --host ${cfg.host} --port ${toString cfg.port} ${lib.concatStringsSep " " cfg.extraFlags}";
        Restart = "on-failure";
        RestartSec = "5s";

        # 网络隔离
        IPAddressDeny = lib.mkIf cfg.offline [ "any" ];
        IPAddressAllow = lib.mkIf cfg.offline [ "localhost" ];

        # 安全与 Hardening
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";

        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ReadWritePaths = [ cfg.dataDir ];

        PrivateTmp = true;
        PrivateMounts = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";

        PrivateDevices = true;
        MemoryDenyWriteExecute = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictNamespaces = true;
        RestrictSUIDSGID = true;

        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
      };
    };
  };
}
