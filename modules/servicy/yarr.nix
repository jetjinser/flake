{
  lib,
  pkgs,
  config,
  ...
}:

let
  defaultUser = "yarr";
  cfg = config.servicy.yarr;
in
with lib;
{
  options.servicy.yarr = {
    enable = mkEnableOption "Whether to enable yarr";
    package = mkOption {
      type = types.package;
      default = pkgs.yarr;
    };

    user = mkOption {
      type = types.str;
      default = defaultUser;
      description = lib.mdDoc "User account under which yarr runs.";
    };

    group = mkOption {
      type = types.str;
      default = defaultUser;
      description = lib.mdDoc "Group under which yarr runs.";
    };

    addr = mkOption {
      type = types.str;
      description = mdDoc "address to run server on";
      example = "0.0.0.0:8080";
      default = "127.0.0.1:7070";
    };

    auth = mkOption {
      type = types.str;
      description = mdDoc "string with username and password in the format `username:password`";
      example = "alice:123abc";
      default = "";
    };
    authFile = mkOption {
      type = types.path;
      description = mdDoc "path to a file containing `username:password`. Takes precedence over `auth`";
      example = "/run/secrets/yarrAuth";
    };

    baseUrl = mkOption {
      type = types.str;
      description = mdDoc "base path of the service url";
      example = "/feeder";
      default = "";
    };

    certFile = mkOption {
      type = with types; nullOr path;
      description = mdDoc "path to cert file for https";
      example = /path/to/cert.pem;
      default = null;
    };

    dbPath = mkOption {
      type = types.path;
      description = mdDoc "storage file path";
      example = "/path/to/storage.db";
      default = "/var/lib/yarr/storage.db";
    };

    keyFile = mkOption {
      type = with types; nullOr path;
      description = "path to key file for https";
      default = null;
    };

    logFile = mkOption {
      type = with types; nullOr path;
      description = "path to log file to use instead of stdout";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.yarr = {
      description = "yarr main service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = getExe' cfg.package "yarr";
        DynamicUser = true;
        StateDirectory = "yarr";
        RuntimeDirectory = "yarr";
        LogsDirectory = "yarr";
        Restart = "on-failure";
        WorkingDirectory = "/var/lib/yarr";

        User = cfg.user;
        Group = cfg.group;
      };
      environment = {
        HOME = "/var/lib/yarr";

        YARR_ADDR = cfg.addr;
        YARR_AUTH = cfg.auth;
        YARR_AUTHFILE = cfg.authFile;
        YARR_BASE = cfg.baseUrl;
        YARR_CERTFILE = cfg.certFile;
        YARR_DB = cfg.dbPath;
        YARR_KEYFILE = cfg.keyFile;
        YARR_LOGFILE = cfg.logFile;
      };
    };

    users.users = mkIf (cfg.user == defaultUser) {
      ${defaultUser} = {
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == defaultUser) {
      ${defaultUser} = { };
    };
  };
}
