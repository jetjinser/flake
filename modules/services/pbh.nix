{
  config,
  pkgs,
  lib,
  ...
}:

let
  defaultUser = "PBH";
  cfg = config.services.peer-ban-helper;
in
{
  options.services.peer-ban-helper = {
    enable = lib.mkEnableOption (lib.mdDoc "Whether to enable PBH.");
    package = lib.mkPackageOption pkgs "peer-ban-helper" { };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = lib.mdDoc ''
        User under which the service should run. If this is the default value,
        the user will be created, with the specified group as the primary
        group.
      '';
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = lib.mdDoc ''
        Group under which the service should run. If this is the default value,
        the group will be created.
      '';
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };
    port = lib.mkOption {
      type = lib.types.port;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services."peerbanhelper" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      script = ''
        touch "disable-update-check.txt"
        exec "${lib.getExe' cfg.package "peer-ban-helper"}" \
            -XX:SoftMaxHeapSize=512M \
            -XX:ZUncommitDelay=30 \
            -XX:+UseStringDeduplication \
            -Dpbh.release="nixos" \
            -Dpbh.serverAddress="${cfg.address}" \
            -Dpbh.port="${toString cfg.port}" \
            -Dpbh.logsdir="$LOGS_DIRECTORY" \
            -Dpbh.configdir="$STATE_DIRECTORY/config" \
            -Dpbh.datadir="$STATE_DIRECTORY/data" \
            -Dpbh.userLocale="zh-CN"
      '';
      serviceConfig = rec {
        StateDirectory = "peerbanhelper";
        RuntimeDirectory = "peerbanhelper";
        LogsDirectory = "peerbanhelper";
        User = cfg.user;
        Group = cfg.group;
        DynamicUser = true;
        MemoryDenyWriteExecute = lib.mkForce false; # for jit
        ProcSubset = lib.mkForce "all";
        WorkingDirectory = "%S/${StateDirectory}";
      };
      description = "PeerBanHelper";
    };
  };
}
