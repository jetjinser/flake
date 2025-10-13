# adapted from https://github.com/berberman/flakes/blob/master/modules/luoxu.nix

{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.services.luoxu;
  user = "luoxu";
  group = "luoxu";
  state = "/var/lib/luoxu";

  inherit (lib)
    mkEnableOption
    mkPackageOption
    mkOption
    types
    ;
in
{
  options.services.luoxu = {
    enable = mkEnableOption "luoxu";
    package = mkPackageOption pkgs "luoxu" { };
    configFile = mkOption {
      type = types.path;
      description = "Path to the luoxu config file";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${user} = {
      isNormalUser = true;
      inherit group;
    };
    users.groups.${group} = { };

    services.postgresql = {
      enable = true;
      ensureDatabases = [ "luoxu" ];
      ensureUsers = [
        {
          name = user;
          ensureDBOwnership = true;
        }
      ];
      extensions = [ pkgs.postgresqlPackages.pgroonga ];
      authentication = ''
        local ${user} ${user} trust
        host  ${user} ${user} 127.0.0.1/32 trust
        host  ${user} ${user} ::1/128      trust
      '';
    };

    systemd.services.luoxu = {
      description = "luoxu";
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" ];
      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;
        ExecStart = "${cfg.package}/bin/luoxu --config ${cfg.configFile}";
        Restart = "always";
        RestartSec = "10";
        WorkingDirectory = state;
      };
    };
    systemd.services.luoxu-dbsetup = {
      description = "Initialize luoxu database";
      after = [ "postgresql.service" ];
      wantedBy = [ "luoxu.service" ]; # 或 multi-user.target
      serviceConfig = {
        Type = "oneshot";
        User = user;
        ExecStart = "${pkgs.postgresql}/bin/psql -d luoxu -f ${cfg.package}/share/luoxu/dbsetup.sql";
      };
    };
  };
}
