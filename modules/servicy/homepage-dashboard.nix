{ config
, pkgs
, lib
, ...
}:

let
  cfg = config.servicy.homepage-dashboard;
in
{
  options = {
    servicy.homepage-dashboard = {
      enable = lib.mkEnableOption (lib.mdDoc "Homepage Dashboard");

      package = lib.mkPackageOption pkgs "homepage-dashboard" { };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc "Open ports in the firewall for Homepage.";
      };

      listenPort = lib.mkOption {
        type = lib.types.int;
        default = 8082;
        description = lib.mdDoc "Port for Homepage to bind to.";
      };

      configPath = lib.mkOption {
        type = with lib.types; nullOr path;
        default = null;
        description = lib.mdDoc "The directory where `settings.yaml` is located.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.homepage-dashboard = {
      description = "Homepage Dashboard";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOMEPAGE_CONFIG_DIR = "/var/lib/homepage-dashboard";
        PORT = "${toString cfg.listenPort}";
      };

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        StateDirectory = "homepage-dashboard";
        ExecStart = "${lib.getExe cfg.package}";
        Restart = "on-failure";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.listenPort ];
    };

    system.activationScripts.mvHomepageDashboardConfig =
      lib.mkIf (!builtins.isNull cfg.configPath)
        (lib.stringAfter [ "var" ] ''
          cp ${cfg.configPath} /var/lib/homepage-dashboard/settings.yaml
        '');
  };
}
