# https://github.com/NixOS/nixpkgs/pull/353890
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.seaweedfs;
  baseDir = "/var/lib/seaweedfs";

  optionsFormat = pkgs.formats.keyValue { listToValue = lib.concatStringsSep ","; };
  optionsFilter = lib.filterAttrs (_: v: null != v && [ ] != v);

  masterOptions = optionsFormat.generate "options.txt" (optionsFilter cfg.master.optionsCLI);

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

    master = {
      enable = lib.mkEnableOption "SeaweedFS master server";

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

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "${baseDir}/master";
        description = "Data directory for master.";
      };
    };

    volume = {
      enable = lib.mkEnableOption "SeaweedFS volume server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for volume server.";
      };

      grpcPort = lib.mkOption {
        type = lib.types.port;
        default = 18080;
        description = "gRPC port for volume server.";
      };

      ip = lib.mkOption {
        type = lib.types.str;
        description = "IP address to bind to.";
      };

      ipBind = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "IP address to bind to. If empty, defaults to same as ip.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "${baseDir}/volume";
        description = "Data directory for volume.";
      };

      master = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "192.168.1.10:9333"
          "192.168.1.11:9333"
        ];
        description = "List of master servers addresses.";
      };

      maxVolumes = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 8;
        description = "Maximum numbers of volumes, count[,count]... If set to zero, the limit will be auto configured as free disk space divided by volume size.";
      };

      dataCenter = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Current volume server's data center name.";
      };

      rack = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Current volume server's rack name.";
      };

      disk = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "[hdd|ssd|<tag>] hard drive or solid state drive or any tag.";
      };

      idxDir = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Directory to store .idx files.";
      };

      index = lib.mkOption {
        type = lib.types.enum [
          "memory"
          "leveldb"
          "leveldbMedium"
          "leveldbLarge"
        ];
        default = "memory";
        description = "Mode for memory~performance balance.";
      };

      readMode = lib.mkOption {
        type = lib.types.enum [
          "local"
          "proxy"
          "redirect"
        ];
        default = "proxy";
        description = "How to deal with non-local volume: not found|proxy to remote node|redirect volume location.";
      };

      minFreeSpace = lib.mkOption {
        type = lib.types.str;
        default = "1";
        description = "Min free disk space (value<=100 as percentage like 1, other as human readable bytes, like 10GiB).";
      };

      fileSizeLimitMB = lib.mkOption {
        type = lib.types.ints.positive;
        default = 256;
        description = "Limit file size to avoid out of memory.";
      };

      metricsPort = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = "Prometheus metrics listen port.";
      };

      whiteList = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Ip addresses having write permission. No limit if empty.";
      };
    };

    filer = {
      enable = lib.mkEnableOption "SeaweedFS filer server";

      port = lib.mkOption {
        type = lib.types.port;
        default = 8888;
        description = "Port for filer server.";
      };

      grpcPort = lib.mkOption {
        type = lib.types.port;
        default = 18888;
        description = "gRPC port for filer server.";
      };

      ip = lib.mkOption {
        type = lib.types.str;
        description = "IP address to bind to.";
      };

      ipBind = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "IP address to bind to. If empty, defaults to same as ip.";
      };

      collection = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "All data will be stored in this default collection.";
      };

      dataDir = lib.mkOption {
        type = lib.types.str;
        default = "${baseDir}/filer";
        description = "Data directory for filer.";
      };

      defaultReplicaPlacement = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Default replication type. If not specified, use master setting.";
      };

      master = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "192.168.1.10:9333"
          "192.168.1.11:9333"
        ];
        description = "List of master servers addresses.";
      };

      maxMB = lib.mkOption {
        type = lib.types.ints.positive;
        default = 4;
        description = "Split files larger than the limit.";
      };

      metricsPort = lib.mkOption {
        type = lib.types.nullOr lib.types.port;
        default = null;
        description = "Prometheus metrics listen port.";
      };

      s3 = {
        enable = lib.mkEnableOption "S3 gateway for filer";

        port = lib.mkOption {
          type = lib.types.port;
          default = 8333;
          description = "S3 server http listen port.";
        };

        grpcPort = lib.mkOption {
          type = lib.types.nullOr lib.types.port;
          default = null;
          description = "S3 server grpc listen port.";
        };

        httpsPort = lib.mkOption {
          type = lib.types.nullOr lib.types.port;
          default = null;
          description = "S3 server https listen port.";
        };

        allowDeleteBucketNotEmpty = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Allow recursive deleting all entries along with bucket.";
        };

        allowEmptyFolder = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Allow empty folders.";
        };

        allowedOrigins = lib.mkOption {
          type = lib.types.str;
          default = "*";
          description = "Comma separated list of allowed origins.";
        };

        domainName = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Suffix of the host name in comma separated list, {bucket}.{domainName}.";
        };

        dataCenter = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Prefer to read and write to volumes in this data center.";
        };

        cert = {
          file = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the TLS certificate file.";
          };

          key = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Path to the TLS private key file.";
          };
        };

        auditLogConfig = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to the audit log config file.";
        };

        config = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to the S3 config file.";
        };
      };

      tomlConfig = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = ''
          Direct TOML configuration for filer.toml.
          Example:
            [filer.options]
            recursive_delete = false
            [redis2]
            enabled = true
            address = "localhost:6379"
            password = ""
            database = 0
        '';
      };

      webdav = {
        enable = lib.mkEnableOption "WebDAV support for filer";

        port = lib.mkOption {
          type = lib.types.port;
          default = 7333;
          description = "WebDAV server http listen port.";
        };

        path = lib.mkOption {
          type = lib.types.str;
          default = "/";
          description = "Use this remote path from filer server.";
        };

        collection = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "Collection to create the files.";
        };

        cacheDir = lib.mkOption {
          type = lib.types.str;
          default = "${baseDir}/webdav-cache";
          description = "Local cache directory for file chunks.";
        };

        cacheCapacityMB = lib.mkOption {
          type = lib.types.ints.positive;
          default = 1000;
          description = "Local cache capacity in MB.";
        };

        disk = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "[hdd|ssd|<tag>] hard drive or solid state drive or any tag.";
        };

        replication = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = ''
            Replication strategy for the files:
            - null: No replication
            - "000": No replication
            - "001": Replicate on one volume
            - "010": Replicate on one rack
            - "100": Replicate on one datacenter
            - "002": Replicate on two volumes
            - "020": Replicate on two racks
            - "200": Replicate on two datacenters
            - "003": Replicate on three volumes
            - "030": Replicate on three racks
            - "300": Replicate on three datacenters
          '';
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      users.users.seaweedfs = {
        isSystemUser = true;
        group = "seaweedfs";
        home = baseDir;
        createHome = true;
      };

      users.groups.seaweedfs = { };

      systemd.tmpfiles = {
        settings = lib.mkMerge [
          {
            "seaweedfs-base" = {
              "${baseDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };

            "seaweedfs-master" = {
              "${cfg.master.dataDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };

            "seaweedfs-volume" = {
              "${cfg.volume.dataDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };

            "seaweedfs-filer" = {
              "${cfg.filer.dataDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };

            "seaweedfs-webdav" = {
              "${cfg.filer.webdav.cacheDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };
          }
          (lib.mkIf (cfg.volume.idxDir != null) {
            seaweedfs-idx = {
              "${cfg.volume.idxDir}".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
            };
          })
          (lib.mkIf (cfg.filer.tomlConfig != null) {
            seaweedfs-config = {
              "${baseDir}/.seaweedfs".d = {
                mode = "0755";
                user = "seaweedfs";
                group = "seaweedfs";
              };
              "${baseDir}/.seaweedfs/filer.toml".f = {
                mode = "0644";
                user = "seaweedfs";
                group = "seaweedfs";
                content = cfg.filer.tomlConfig;
              };
            };
          })
        ];
      };
    })

    (lib.mkIf (cfg.enable && cfg.master.enable) {
      systemd.services.seaweedfs-master = {
        description = "SeaweedFS Master Server";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/weed master -options=${masterOptions}";
          User = "seaweedfs";
          Group = "seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "30s";
          WorkingDirectory = cfg.master.dataDir;
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

        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/weed volume \
              -port=${toString cfg.volume.port} \
              ${lib.optionalString (cfg.volume.grpcPort != null) "-port.grpc=${toString cfg.volume.grpcPort}"} \
              -ip=${cfg.volume.ip} \
              ${lib.optionalString (cfg.volume.ipBind != "") "-ip.bind=${cfg.volume.ipBind}"} \
              -dir=${cfg.volume.dataDir} \
              -mserver=${lib.concatStringsSep "," cfg.volume.master} \
              -max=${toString cfg.volume.maxVolumes} \
              ${lib.optionalString (cfg.volume.dataCenter != "") "-dataCenter=${cfg.volume.dataCenter}"} \
              ${lib.optionalString (cfg.volume.rack != "") "-rack=${cfg.volume.rack}"} \
              ${lib.optionalString (cfg.volume.disk != "") "-disk=${cfg.volume.disk}"} \
              ${lib.optionalString (cfg.volume.idxDir != null) "-dir.idx=${cfg.volume.idxDir}"} \
              -index=${cfg.volume.index} \
              -readMode=${cfg.volume.readMode} \
              -minFreeSpace=${cfg.volume.minFreeSpace} \
              -fileSizeLimitMB=${toString cfg.volume.fileSizeLimitMB} \
              ${
                lib.optionalString (
                  cfg.volume.metricsPort != null
                ) "-metricsPort=${toString cfg.volume.metricsPort}"
              } \
              ${lib.optionalString (
                cfg.volume.whiteList != [ ]
              ) "-whiteList=${lib.concatStringsSep "," cfg.volume.whiteList}"}
          '';
          User = "seaweedfs";
          Group = "seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "45s";
          WorkingDirectory = cfg.volume.dataDir;
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

        serviceConfig = {
          ExecStart =
            let
              s3Args = lib.optionalString cfg.filer.s3.enable (
                lib.concatStringsSep " " [
                  "-s3"
                  (lib.optionalString (cfg.filer.s3.port != null) "-s3.port=${toString cfg.filer.s3.port}")
                  (lib.optionalString (
                    cfg.filer.s3.grpcPort != null
                  ) "-s3.port.grpc=${toString cfg.filer.s3.grpcPort}")
                  (lib.optionalString (
                    cfg.filer.s3.httpsPort != null
                  ) "-s3.port.https=${toString cfg.filer.s3.httpsPort}")
                  (lib.optionalString (!cfg.filer.s3.allowDeleteBucketNotEmpty) "-s3.allowDeleteBucketNotEmpty=false")
                  (lib.optionalString (!cfg.filer.s3.allowEmptyFolder) "-s3.allowEmptyFolder=false")
                  (lib.optionalString (
                    cfg.filer.s3.allowedOrigins != "*"
                  ) "-s3.allowedOrigins=${cfg.filer.s3.allowedOrigins}")
                  (lib.optionalString (cfg.filer.s3.domainName != null) "-s3.domainName=${cfg.filer.s3.domainName}")
                  (lib.optionalString (cfg.filer.s3.dataCenter != "") "-s3.dataCenter=${cfg.filer.s3.dataCenter}")
                  (lib.optionalString (
                    cfg.filer.s3.cert.file != null
                  ) "-s3.cert.file=${toString cfg.filer.s3.cert.file}")
                  (lib.optionalString (
                    cfg.filer.s3.cert.key != null
                  ) "-s3.key.file=${toString cfg.filer.s3.cert.key}")
                  (lib.optionalString (
                    cfg.filer.s3.auditLogConfig != null
                  ) "-s3.auditLogConfig=${toString cfg.filer.s3.auditLogConfig}")
                  (lib.optionalString (cfg.filer.s3.config != null) "-s3.config=${toString cfg.filer.s3.config}")
                ]
              );

              webdavArgs = lib.optionalString cfg.filer.webdav.enable (
                lib.concatStringsSep " " [
                  "-webdav"
                  "-webdav.port=${toString cfg.filer.webdav.port}"
                  (lib.optionalString (
                    cfg.filer.webdav.collection != ""
                  ) "-webdav.collection=${cfg.filer.webdav.collection}")
                  "-webdav.cacheDir=${cfg.filer.webdav.cacheDir}"
                  "-webdav.cacheCapacityMB=${toString cfg.filer.webdav.cacheCapacityMB}"
                  (lib.optionalString (cfg.filer.webdav.disk != "") "-webdav.disk=${cfg.filer.webdav.disk}")
                  (lib.optionalString (
                    cfg.filer.webdav.replication != ""
                  ) "-webdav.replication=${cfg.filer.webdav.replication}")
                ]
              );

              baseArgs = lib.concatStringsSep " \\\n  " [
                "${cfg.package}/bin/weed filer"
                "-port=${toString cfg.filer.port}"
                "-ip=${cfg.filer.ip}"
                "-master=${lib.concatStringsSep "," cfg.filer.master}"
                "-defaultStoreDir=${cfg.filer.dataDir}"
                "-maxMB=${toString cfg.filer.maxMB}"
                (lib.optionalString (cfg.filer.grpcPort != null) "-port.grpc=${toString cfg.filer.grpcPort}")
                (lib.optionalString (cfg.filer.ipBind != "") "-ip.bind=${cfg.filer.ipBind}")
                (lib.optionalString (cfg.filer.collection != "") "-collection=${cfg.filer.collection}")
                (lib.optionalString (
                  cfg.filer.defaultReplicaPlacement != ""
                ) "-defaultReplicaPlacement=${cfg.filer.defaultReplicaPlacement}")
                (lib.optionalString (
                  cfg.filer.metricsPort != null
                ) "-metricsPort=${toString cfg.filer.metricsPort}")
              ];
            in
            ''
              ${baseArgs} \
                ${s3Args} \
                ${webdavArgs}
            '';
          User = "seaweedfs";
          Group = "seaweedfs";
          StateDirectory = "seaweedfs";
          RuntimeDirectory = "seaweedfs";
          Restart = "always";
          RestartSec = "60s";
          WorkingDirectory = cfg.filer.dataDir;
          LimitNOFILE = 65535;
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        };
      };
    })

    (lib.mkIf (cfg.enable && cfg.openFirewall) {
      networking.firewall.allowedTCPPorts = lib.filter (p: p != null) (
        lib.flatten [
          # Master ports
          (lib.optionals cfg.master.enable [
            cfg.master.port
            cfg.master.grpcPort
          ])
          # Volume ports
          (lib.optionals cfg.volume.enable [
            cfg.volume.port
            cfg.volume.grpcPort
          ])
          # Filer ports
          (lib.optionals cfg.filer.enable [
            cfg.filer.port
            cfg.filer.grpcPort
          ])
          # S3 ports
          (lib.optionals (cfg.filer.enable && cfg.filer.s3.enable) [
            cfg.filer.s3.port
            cfg.filer.s3.grpcPort
            cfg.filer.s3.httpsPort
          ])
          # WebDAV port
          (lib.optionals (cfg.filer.enable && cfg.filer.webdav.enable) [
            cfg.filer.webdav.port
          ])
          # Metrics ports
          (lib.optionals (cfg.master.enable && cfg.master.metricsPort != null) [
            cfg.master.metricsPort
            cfg.volume.metricsPort
            cfg.filer.metricsPort
          ])
        ]
      );
    })
  ];
}
