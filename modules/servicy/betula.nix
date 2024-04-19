{ lib
, pkgs
, config
, ...
}:

let
  defaultUser = "betula";
  cfg = config.servicy.betula;
in
with lib;
{
  options.servicy.betula = {
    enable = mkEnableOption "Whether to enable yarr";
    package = mkOption {
      type = types.package;
      default = pkgs.betula;
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
      description = "User account under which betula runs.";
    };

    group = mkOption {
      type = types.str;
      default = defaultUser;
      description = "Group under which betula runs.";
    };

    port = mkOption {
      type = types.port;
      default = 1738;
      description = "The betula port number. The value gets written to a database file.";
    };

    openFirewall = lib.mkEnableOption "Open ports in the firewall for wakapi.";
  };

  config = mkIf cfg.enable
    {
      users.users = mkIf (cfg.user == defaultUser) {
        ${defaultUser} = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };

      users.groups = mkIf (cfg.group == defaultUser) {
        ${defaultUser} = { };
      };

      networking.firewall.allowedTCPPorts =
        lib.mkIf cfg.openFirewall [ cfg.port ];

      systemd.services.betula = {
        description = "betula service";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        script =
          let
            betula = getExe' cfg.package "betula";
          in
          ''
            ${betula} links.betula -port ${cfg.port}
          '';

        serviceConfig = {
          ExecStart = getExe' cfg.package "yarr";
          DynamicUser = true;
          StateDirectory = "betula";
          RuntimeDirectory = "betula";
          LogsDirectory = "betula";
          Restart = "on-failure";
          WorkingDirectory = "/var/lib/betula";

          User = cfg.user;
          Group = cfg.group;
        };
      };
    };
}
