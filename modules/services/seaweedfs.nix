# https://github.com/NixOS/nixpkgs/pull/353890
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seaweedfs;

  optionsFormat = pkgs.formats.keyValue { listToValue = lib.concatStringsSep ","; };
  optionsFilter = lib.filterAttrs (_: v: null != v && [ ] != v);

  masterOptions = optionsFormat.generate "master-options.txt" (optionsFilter cfg.master.optionsCLI);
  volumeOptions = optionsFormat.generate "volume-options.txt" (optionsFilter cfg.volume.optionsCLI);
  filerOptions = optionsFormat.generate "filer-options.txt" (optionsFilter cfg.filer.optionsCLI);

  settingsFormat = pkgs.formats.toml { };
  filerSettings = settingsFormat.generate "filer.toml" (cfg.settings.filer);
  notificationSettings = settingsFormat.generate "notification.toml" (cfg.settings.notification);
  replicationSettings = settingsFormat.generate "replication.toml" (cfg.settings.replication);
  securitySettings = settingsFormat.generate "security.toml" (cfg.settings.security);
  masterSettings = settingsFormat.generate "master.toml" (cfg.settings.master);
  shellSettings = settingsFormat.generate "shell.toml" (cfg.settings.shell);
  credentialSettings = settingsFormat.generate "credential.toml" (cfg.settings.credential);

  seaweedfsConfigTomls = pkgs.runCommandLocal "seaweedfs-config-tomls" { } ''
    mkdir -p $out/.seaweedfs
    cp ${filerSettings}        $out/.seaweedfs/filer.toml
    cp ${notificationSettings} $out/.seaweedfs/notification.toml
    cp ${replicationSettings}  $out/.seaweedfs/replication.toml
    cp ${securitySettings}     $out/.seaweedfs/security.toml
    cp ${masterSettings}       $out/.seaweedfs/master.toml
    cp ${shellSettings}        $out/.seaweedfs/shell.toml
    cp ${credentialSettings}   $out/.seaweedfs/credential.toml
  '';

  mkMkOption =
    type: default: description:
    lib.mkOption {
      inherit type default description;
    };
  mkNullOrStrOption = mkMkOption (with lib.types; nullOr str) null;
  mkNullOrUIntsOption = mkMkOption (with lib.types; nullOr ints.unsigned) null;
  mkNullOrPortOption = mkMkOption (with lib.types; nullOr port) null;
in
{
  options.services.seaweedfs = {
    enable = lib.mkEnableOption "SeaweedFS";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open ports in the firewall for SeaweedFS services.";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.seaweedfs;
      defaultText = lib.literalExpression "pkgs.seaweedfs";
      description = "The SeaweedFS package to use.";
    };

    settings =
      lib.genAttrs
        [
          "filer"
          "notification"
          "replication"
          "security"
          "master"
          "shell"
          "credential"
        ]
        (
          _:
          lib.mkOption {
            type = lib.types.submodule {
              freeformType = settingsFormat.type;
              options = { };
            };
            default = { };
          }
        );

    master = {
      enable = lib.mkEnableOption "SeaweedFS master server";

      # master optionsCLI {{{
      optionsCLI = lib.mkOption {
        type = lib.types.submodule {
          freeformType = optionsFormat.type;
          options = {
            cpuprofile = mkNullOrStrOption ''
              cpu profile output file
            '';
            defaultReplication = mkNullOrStrOption ''
              Default replication type if not specified.
            '';
            disableHttp = lib.mkEnableOption ''
              disable http requests, only gRPC operations are allowed.
            '';
            garbageThreshold = lib.mkOption {
              type = with lib.types; nullOr float;
              default = null;
              description = "Threshold to vacuum and reclaim spaces.";
            };
            electionTimeout = mkNullOrStrOption ''
              heartbeat interval of master servers, and will be randomly multiplied by [1, 1.25) (default 300ms)
            '';
            ip = mkNullOrStrOption ''
              master <ip>|<server> address, also used as identifier (default current hostname)
            '';
            "ip.bind" = mkNullOrStrOption ''
              ip address to bind to. If empty, default to same as -ip option.
            '';
            maxParallelVacuumPerServer = mkNullOrUIntsOption ''
              maximum number of volumes to vacuum in parallel per volume server (default 1)
            '';
            mdir = mkNullOrStrOption ''
              data directory to store meta data (default "/tmp")
            '';
            memprofile = mkNullOrStrOption ''
              memory profile output file
            '';
            "metrics.address" = mkNullOrStrOption ''
              Prometheus gateway address <host>:<port>
            '';
            "metrics.intervalSeconds" = mkNullOrStrOption ''
              Prometheus push interval in seconds (default 15)
            '';
            metricsIp = mkNullOrStrOption ''
              metrics listen ip. If empty, default to same as -ip.bind option.
            '';
            metricsPort = mkNullOrPortOption ''
              Prometheus metrics listen port
            '';
            peers = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              example = [
                "192.168.1.10:9333"
                "192.168.1.11:9333"
              ];
              description = ''
                all master nodes in ip:port list
              '';
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 9333;
              description = "Port for master server.";
            };
            "port.grpc" = lib.mkOption {
              type = lib.types.port;
              default = 19333;
              description = "gRPC port for master server.";
            };
            raftBootstrap = lib.mkEnableOption ''
              Whether to bootstrap the Raft cluster
            '';
            raftHashicorp = lib.mkEnableOption ''
              use hashicorp raft
            '';
            resumeState = lib.mkEnableOption ''
              resume previous state on start master server
            '';
            telemetry = lib.mkEnableOption ''
              enable telemetry reporting
            '';
            "telemetry.url" = mkNullOrStrOption ''
              telemetry server URL to send usage statistics (default "https://telemetry.seaweedfs.com/api/collect")
            '';
            volumePreallocate = lib.mkEnableOption ''
              Preallocate disk space for volumes.
            '';
            volumeSizeLimitMB = mkNullOrUIntsOption ''
              Master stops directing writes to oversized volumes. (default 30000)
            '';
            whiteList = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = ''
                list Ip addresses having write permission. No limit if empty.
              '';
            };
          };
        };
        description = ''
          Command line options passed to weed master
        '';
      };
      # }}}
    };

    volume = {
      enable = lib.mkEnableOption "SeaweedFS volume server";

      # volume optionsCLI {{{
      optionsCLI = lib.mkOption {
        type = lib.types.submodule {
          freeformType = optionsFormat.type;
          options = {
            compactionMBps = mkNullOrUIntsOption ''
              Limit background compaction or copying speed in MB/s.
            '';
            concurrentDownloadLimitMB = mkNullOrUIntsOption ''
              Limit total concurrent download size (default 256).
            '';
            concurrentUploadLimitMB = mkNullOrUIntsOption ''
              Limit total concurrent upload size (default 256).
            '';
            cpuprofile = mkNullOrStrOption ''
              CPU profile output file.
            '';
            dataCenter = mkNullOrStrOption ''
              Current volume server's data center name.
            '';
            dir = mkNullOrStrOption ''
              Directories to store data files. dir[,dir]... (default "/tmp").
            '';
            "dir.idx" = mkNullOrStrOption ''
              Directory to store .idx files.
            '';
            disk = mkNullOrStrOption ''
              [hdd|ssd|<tag>] hard drive or solid state drive or any tag.
            '';
            fileSizeLimitMB = mkNullOrUIntsOption ''
              Limit file size to avoid out of memory (default 256).
            '';
            hasSlowRead = lib.mkEnableOption ''
              Prevent slow reads from blocking other requests, but large file read P99 latency will increase. (default true)
            '';
            idleTimeout = mkNullOrUIntsOption ''
              Connection idle seconds (default 30).
            '';
            "images.fix.orientation" = lib.mkEnableOption ''
              Adjust jpg orientation when uploading.
            '';
            index = lib.mkOption {
              type = lib.types.enum [
                "memory"
                "leveldb"
                "leveldbMedium"
                "leveldbLarge"
              ];
              default = "memory";
              description = ''
                Choose [memory|leveldb|leveldbMedium|leveldbLarge] mode for memory~performance balance. (default "memory").
              '';
            };
            "index.leveldbTimeout" = mkNullOrUIntsOption ''
              Alive time for leveldb (default to 0). If leveldb of volume is not accessed in ldbTimeout hours, it will be off loaded.
            '';
            inflightDownloadDataTimeout = mkNullOrStrOption ''
              Inflight download data wait timeout of volume servers (default 1m0s).
            '';
            inflightUploadDataTimeout = mkNullOrStrOption ''
              Inflight upload data wait timeout of volume servers (default 1m0s).
            '';
            ip = mkNullOrStrOption ''
              IP or server name, also used as identifier (default "192.168.31.111").
            '';
            "ip.bind" = mkNullOrStrOption ''
              IP address to bind to. If empty, default to same as -ip option.
            '';
            max = mkNullOrUIntsOption ''
              Maximum numbers of volumes, count[,count]... (default "8").
            '';
            memprofile = mkNullOrStrOption ''
              Memory profile output file.
            '';
            metricsIp = mkNullOrStrOption ''
              Metrics listen IP. If empty, default to same as -ip.bind option.
            '';
            metricsPort = mkNullOrPortOption ''
              Prometheus metrics listen port.
            '';
            minFreeSpace = mkNullOrStrOption ''
              Minimum free disk space (<=100 as percentage, otherwise bytes like 10GiB).
            '';
            minFreeSpacePercent = mkNullOrStrOption ''
              Minimum free disk space (default to 1%). Deprecated, use minFreeSpace instead.
            '';
            mserver = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              example = [
                "192.168.1.10:9333"
                "192.168.1.11:9333"
              ];
              description = ''
                list master servers (default "localhost:9333").
              '';
            };
            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              description = "HTTP listen port (default 8080).";
            };
            "port.grpc" = lib.mkOption {
              type = lib.types.port;
              default = 18080;
              description = "gRPC port for volume server.";
            };
            "port.public" = mkNullOrPortOption "Port opened to public.";
            pprof = lib.mkEnableOption ''
              Enable pprof http handlers. Precludes --memprofile and --cpuprofile.
            '';
            preStopSeconds = mkNullOrUIntsOption ''
              Number of seconds between stop send heartbeats and stop volume server (default 10).
            '';
            publicUrl = mkNullOrStrOption ''
              Publicly accessible address.
            '';
            rack = mkNullOrStrOption ''
              Current volume server's rack name.
            '';
            readBufferSizeMB = mkNullOrUIntsOption ''
              Larger values can optimize query performance but will increase memory usage. (default 4)
            '';
            readMode = lib.mkOption {
              type = lib.types.enum [
                "local"
                "proxy"
                "redirect"
              ];
              default = "proxy";
              description = "How to deal with non-local volume: not found|proxy to remote node|redirect volume location.";
            };
            whiteList = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = ''
                list Ip addresses having write permission. No limit if empty.
              '';
            };
          };
        };
        description = ''
          Command line options passed to weed volume
        '';
      };
      # }}}
    };

    filer = {
      enable = lib.mkEnableOption "SeaweedFS filer server";

      # filer optionsCLI {{{
      optionsCLI = lib.mkOption {
        type = lib.types.submodule {
          freeformType = optionsFormat.type;
          options = {
            allowedOrigins = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = "List of allowed origins.";
            };
            collection = mkNullOrStrOption ''
              All data will be stored in this default collection.
            '';
            concurrentUploadLimitMB = mkNullOrUIntsOption ''
              Limit total concurrent upload size (default 128).
            '';
            dataCenter = mkNullOrStrOption ''
              Prefer to read and write to volumes in this data center.
            '';
            debug = lib.mkEnableOption ''
              Serves runtime profiling data.
            '';
            "debug.port" = lib.mkOption {
              type = lib.types.port;
              default = 6060;
              description = "HTTP port for debugging (default 6060).";
            };
            defaultReplicaPlacement = mkNullOrStrOption ''
              Default replication type. If not specified, use master setting.
            '';
            defaultStoreDir = mkNullOrStrOption ''
              If filer.toml is empty, use an embedded filer store in the directory (default ".").
            '';
            dirListLimit = mkNullOrUIntsOption ''
              Limit sub dir listing size (default 100000).
            '';
            disableDirListing = lib.mkEnableOption ''
              Turn off directory listing.
            '';
            disableHttp = lib.mkEnableOption ''
              Disable http request, only gRPC operations are allowed.
            '';
            disk = mkNullOrStrOption ''
              [hdd|ssd|<tag>] hard drive or solid state drive or any tag.
            '';
            downloadMaxMBps = mkNullOrUIntsOption ''
              Download max speed for each download request, in MB per second.
            '';
            encryptVolumeData = lib.mkEnableOption ''
              Encrypt data on volume servers.
            '';
            exposeDirectoryData = lib.mkEnableOption ''
              Whether to return directory metadata and content in Filer UI (default true).
            '';
            filerGroup = mkNullOrStrOption ''
              Share metadata with other filers in the same filerGroup.
            '';
            iam = lib.mkEnableOption ''
              Whether to start IAM service.
            '';
            "iam.ip" = mkNullOrStrOption ''
              IAM server http listen IP address (default "192.168.31.111").
            '';
            "iam.port" = lib.mkOption {
              type = lib.types.port;
              default = 8111;
              description = "IAM server http listen port (default 8111).";
            };
            ip = mkNullOrStrOption ''
              Filer server http listen IP address (default "192.168.31.111").
            '';
            "ip.bind" = mkNullOrStrOption ''
              IP address to bind to. If empty, default to same as -ip option.
            '';
            localSocket = mkNullOrStrOption ''
              Default to /tmp/seaweedfs-filer-<port>.sock.
            '';
            master = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ "localhost:9333" ];
              description = "List of master servers or a single DNS SRV record.";
            };
            maxMB = mkNullOrUIntsOption ''
              Split files larger than the limit (default 4).
            '';
            metricsIp = mkNullOrStrOption ''
              Metrics listen IP. If empty, default to same as -ip.bind option.
            '';
            metricsPort = mkNullOrPortOption ''
              Prometheus metrics listen port.
            '';
            port = lib.mkOption {
              type = lib.types.port;
              default = 8888;
              description = "Filer server http listen port (default 8888).";
            };
            "port.grpc" = lib.mkOption {
              type = lib.types.port;
              default = 18888;
              description = "Filer server gRPC listen port.";
            };
            "port.readonly" = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Readonly port opened to public.";
            };
            rack = mkNullOrStrOption ''
              Prefer to write to volumes in this rack.
            '';
            s3 = lib.mkEnableOption ''
              Whether to start S3 gateway.
            '';
            "s3.allowDeleteBucketNotEmpty" = lib.mkEnableOption ''
              Allow recursive deleting all entries along with bucket (default true).
            '';
            "s3.allowEmptyFolder" = lib.mkEnableOption ''
              Allow empty folders (default true).
            '';
            "s3.allowedOrigins" = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ "*" ];
              description = "List of allowed origins for S3.";
            };
            "s3.auditLogConfig" = mkNullOrStrOption ''
              Path to the audit log config file.
            '';
            "s3.cacert.file" = mkNullOrStrOption ''
              Path to the TLS CA certificate file.
            '';
            "s3.cert.file" = mkNullOrStrOption ''
              Path to the TLS certificate file.
            '';
            "s3.config" = mkNullOrStrOption ''
              Path to the config file.
            '';
            "s3.dataCenter" = mkNullOrStrOption ''
              Prefer to read and write to volumes in this data center.
            '';
            "s3.domainName" = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              description = "Suffix of the host name in list, {bucket}.{domainName}.";
            };
            "s3.idleTimeout" = mkNullOrUIntsOption ''
              Connection idle seconds (default 10).
            '';
            "s3.ip.bind" = mkNullOrStrOption ''
              IP address to bind to. If empty, default to same as -ip.bind option.
            '';
            "s3.key.file" = mkNullOrStrOption ''
              Path to the TLS private key file.
            '';
            "s3.localSocket" = mkNullOrStrOption ''
              Default to /tmp/seaweedfs-s3-<port>.sock.
            '';
            "s3.port" = lib.mkOption {
              type = lib.types.port;
              default = 8333;
              description = "S3 server http listen port (default 8333).";
            };
            "s3.port.grpc" = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "S3 server gRPC listen port.";
            };
            "s3.port.https" = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "S3 server https listen port.";
            };
            "s3.tlsVerifyClientCert" = lib.mkEnableOption ''
              Whether to verify the client's certificate.
            '';
            saveToFilerLimit = mkNullOrUIntsOption ''
              Files smaller than this limit will be saved in filer store.
            '';
            sftp = lib.mkEnableOption ''
              Whether to start the SFTP server.
            '';
            "sftp.authMethods" = lib.mkOption {
              type = with lib.types; listOf str;
              default = [
                "password"
                "publickey"
              ];
              description = "Allowed auth methods: password, publickey, keyboard-interactive.";
            };
            "sftp.bannerMessage" = mkNullOrStrOption ''
              Message displayed before authentication.
            '';
            "sftp.clientAliveCountMax" = mkNullOrUIntsOption ''
              Maximum number of missed keep-alive messages before disconnecting (default 3).
            '';
            "sftp.clientAliveInterval" = mkNullOrStrOption ''
              Interval for sending keep-alive messages (default 5s).
            '';
            "sftp.dataCenter" = mkNullOrStrOption ''
              Prefer to read and write to volumes in this data center.
            '';
            "sftp.hostKeysFolder" = mkNullOrStrOption ''
              Path to folder containing SSH private key files for host authentication.
            '';
            "sftp.ip.bind" = mkNullOrStrOption ''
              IP address to bind to. If empty, default to same as -ip.bind option.
            '';
            "sftp.localSocket" = mkNullOrStrOption ''
              Default to /tmp/seaweedfs-sftp-<port>.sock.
            '';
            "sftp.loginGraceTime" = mkNullOrStrOption ''
              Timeout for authentication (default 2m0s).
            '';
            "sftp.maxAuthTries" = mkNullOrUIntsOption ''
              Maximum number of authentication attempts per connection (default 6).
            '';
            "sftp.port" = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = 2022;
              description = "SFTP server listen port (default 2022).";
            };
            "sftp.sshPrivateKey" = mkNullOrStrOption ''
              Path to the SSH private key file for host authentication.
            '';
            "sftp.userStoreFile" = mkNullOrStrOption ''
              Path to JSON file containing user credentials and permissions.
            '';
            "ui.deleteDir" = lib.mkEnableOption ''
              Enable filer UI show delete directory button (default true).
            '';
            webdav = lib.mkEnableOption ''
              Whether to start webdav gateway.
            '';
            "webdav.cacheCapacityMB" = mkNullOrUIntsOption ''
              Local cache capacity in MB.
            '';
            "webdav.cacheDir" = mkNullOrStrOption ''
              Local cache directory for file chunks (default "/tmp").
            '';
            "webdav.cert.file" = mkNullOrStrOption ''
              Path to the TLS certificate file.
            '';
            "webdav.collection" = mkNullOrStrOption ''
              Collection to create the files.
            '';
            "webdav.disk" = mkNullOrStrOption ''
              [hdd|ssd|<tag>] hard drive or solid state drive or any tag.
            '';
            "webdav.filer.path" = mkNullOrStrOption ''
              Use this remote path from filer server (default "/").
            '';
            "webdav.key.file" = mkNullOrStrOption ''
              Path to the TLS private key file.
            '';
            "webdav.maxMB" = mkNullOrUIntsOption ''
              Split files larger than the limit (default 4).
            '';
            "webdav.port" = lib.mkOption {
              type = lib.types.nullOr lib.types.port;
              default = 7333;
              description = "Webdav server http listen port (default 7333).";
            };
            "webdav.replication" = mkNullOrStrOption ''
              Replication to create the files.
            '';
            whiteList = lib.mkOption {
              type = with lib.types; listOf str;
              default = [ ];
              example = [
                "192.168.1.10:9333"
                "192.168.1.11:9333"
              ];
              description = "List of IP addresses having write permission. No limit if empty.";
            };
          };
        };
        description = ''
          Command line options passed to weed filer
        '';
      };
      # }}}
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.users.seaweedfs = {
        isSystemUser = true;
        group = "seaweedfs";
        home = "/var/lib/seaweedfs";
        createHome = true;
      };

      users.groups.seaweedfs = { };
    })

    (lib.mkIf (cfg.enable && cfg.master.enable) {
      systemd.services.seaweedfs-master = {
        description = "SeaweedFS Master Server";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        environment.HOME = seaweedfsConfigTomls;
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/weed master -options=${masterOptions}";
          User = "seaweedfs";
          Group = "seaweedfs";
          WorkingDirectory = "%S/seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "30s";
          LimitNOFILE = 65535;
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.volume.enable) {
      systemd.services.seaweedfs-volume = {
        description = "SeaweedFS Volume Server";
        after = [ "network-online.target" ] ++ lib.optional cfg.master.enable "seaweedfs-master.service";
        wants = [ "network-online.target" ];
        requires = lib.optional cfg.master.enable "seaweedfs-master.service";
        wantedBy = [ "multi-user.target" ];

        environment.HOME = seaweedfsConfigTomls;
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/weed volume -options=${volumeOptions}";
          User = "seaweedfs";
          Group = "seaweedfs";
          WorkingDirectory = "%S/seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "45s";
          LimitNOFILE = 65535;
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.filer.enable) {
      systemd.services.seaweedfs-filer = {
        description = "SeaweedFS Filer Server";
        after = [ "network-online.target" ] ++ lib.optional cfg.master.enable "seaweedfs-master.service";
        wants = [ "network-online.target" ];
        requires = lib.optional cfg.master.enable "seaweedfs-master.service";
        wantedBy = [ "multi-user.target" ];

        environment.HOME = seaweedfsConfigTomls;
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/weed filer -options=${filerOptions}";
          User = "seaweedfs";
          Group = "seaweedfs";
          WorkingDirectory = "%S/seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "60s";
          LimitNOFILE = 65535;
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.openFirewall) {
      networking.firewall.allowedTCPPorts = lib.filter (p: p != null) (
        lib.flatten [
          # Master ports
          (lib.optionals cfg.master.enable (
            with cfg.master;
            [
              optionsCLI.port
              optionsCLI."port.grpc"
            ]
          ))
          # Volume ports
          (lib.optionals cfg.volume.enable (
            with cfg.volume;
            [
              optionsCLI.port
              optionsCLI."port.grpc"
            ]
          ))
          # Filer ports
          (lib.optionals cfg.filer.enable (
            with cfg.filer;
            [
              optionsCLI.port
              optionsCLI."port.grpc"
            ]
          ))
          # S3 ports
          (lib.optionals (cfg.filer.enable && cfg.filer.optionsCLI.s3) (
            with cfg.filer;
            [
              optionsCLI."s3.port"
              optionsCLI."s3.port.grpc"
              optionsCLI."s3.port.https"
            ]
          ))
          # WebDAV port
          (lib.optionals (cfg.filer.enable && cfg.filer.optionsCLI.webdav) (
            with cfg.filer;
            [
              optionsCLI."webdav.port"
            ]
          ))
          # Metrics ports
          (lib.optionals (cfg.master.enable && cfg.master.optionsCLI.metricsPort != null) [
            cfg.master.optionsCLI.metricsPort
            cfg.volume.optionsCLI.metricsPort
            cfg.filer.optionsCLI.metricsPort
          ])
        ]
      );
    })
  ];
}
