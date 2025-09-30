{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaultUser = "copilot-api";
  cfg = config.services.copilot-api;
in
{
  options.services.copilot-api = {
    enable = lib.mkEnableOption "Enable the copilot-api service.";

    package = lib.mkOption {
      type = lib.types.package;
      # TODO: overlay
      default = pkgs.callPackage ../pkgs/copilot-api.nix { };
      description = "The copilot-api package to use.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "User account under which copilot-api runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "Group under which copilot-api runs.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 4141;
      description = "Port for copilot-api to listen on.";
    };

    openFirewall = lib.mkEnableOption "Open firewall for copilot-api port.";

    verbose = lib.mkEnableOption "Enable verbose logging.";

    accountType = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "individual"
          "business"
          "enterprise"
        ]
      );
      default = null;
      description = "GitHub account type: business or enterprise.";
    };

    manual = lib.mkEnableOption "Enable manual approval for each request.";

    rateLimit = lib.mkOption {
      type = with lib.types; nullOr ints.positive;
      default = null;
      description = "Rate limit in seconds between requests.";
    };

    waitOnRateLimit = lib.mkEnableOption "Wait instead of error when rate limit is hit.";

    githubTokenFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a file containing the GitHub token.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users = lib.mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = lib.mkIf (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    systemd.services.copilot-api = {
      description = "GitHub Copilot API Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      script =
        let
          copilotArgs = lib.cli.toGNUCommandLine { } {
            inherit (cfg) port;
            inherit (cfg) verbose;
            account-type = cfg.accountType;
            inherit (cfg) manual;
            rate-limit = cfg.rateLimit;
            wait = cfg.waitOnRateLimit;
          };
        in
        ''
          exec ${lib.getExe' cfg.package "copilot-api"} start \
            ${lib.escapeShellArgs copilotArgs} \
            ${lib.optionalString (cfg.githubTokenFile != null) ''
              -g "$(cat ${cfg.githubTokenFile})"
            ''}
        '';

      serviceConfig = {
        DynamicUser = true;
        Environment = "HOME=/var/lib/copilot-api";
        StateDirectory = "copilot-api";
        RuntimeDirectory = "copilot-api";
        LogsDirectory = "copilot-api";
        Restart = "on-failure";
        WorkingDirectory = "/var/lib/copilot-api";
        User = cfg.user;
        Group = cfg.group;
      };
    };
  };
}
