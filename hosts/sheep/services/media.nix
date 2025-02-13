{
  flake,
  config,
  pkgs,
  lib,
  ...
}:

# TODO:
# - metrics
# - PostgreSQL
# - declarative config ASAP
# - maybe some distributed storage
# - unify user & group

let
  inherit (flake.config.symbols.people) myself;
  inherit (config.users) users;

  cfg = config.services;
  tmpfilesSettings = config.systemd.tmpfiles.settings;

  subdomain = "media";

  proxyEnv = rec {
    ALL_PROXY = "http://192.168.114.1:8080";
    HTTP_PROXY = ALL_PROXY;
    HTTPS_PROXY = ALL_PROXY;
    NO_PROXY = "localhost,127.0.0.1";
  };
in
{
  services = {
    jellyfin.enable = true;
    # consider: https://github.com/opspotes/jellyseerr-exporter
    jellyseerr = {
      inherit (cfg.jellyfin) enable;
      package = pkgs.jellyseerr.overrideAttrs (_: {
        # https://github.com/NixOS/nixpkgs/pull/380532
        postBuild = ''
          # Clean up broken symlinks left behind by `pnpm prune`
          find node_modules -xtype l -delete
        '';
      });
    };
    # https://github.com/NixOS/nixpkgs/issues/360592
    # wait for v5 that bump dotnet to 8
    # sonarr.enable = true;
    radarr.enable = cfg.jellyfin.enable;
    prowlarr.enable = cfg.jellyfin.enable;
    # bazarr subtitles
    # bazarr.enable = cfg.jellyfin.enable;

    transmission = {
      inherit (cfg.jellyfin) enable;
      settings = {
        download-dir = "/srv/torrent";
        rpc-username = myself;
        rpc-password = "{2b79a09b99bc2b99da06665666853bd337052a05ypW43WFG";
        ratio-limit-enabled = true; # default: 2.0
        speed-limit-up-enabled = true; # default: 100 KB/s
        speed-limit-down-enabled = false; # default: 100 KB/s
      };
    };
  };

  services.cloudflared'.ingress = {
    ${subdomain} = 8096; # jellyfin
    discovery = cfg.jellyseerr.port; # 5055
    radarr = 7878;
    prowlarr = 9696;
    bazarr = cfg.bazarr.listenPort; # 6767
  };

  systemd.services.setupJellyfin = {
    description = "Setup Jellyfin";
    before = [ "jellyfin.service" ];
    wantedBy = [ "jellyfin.service" ];

    script = ''
      ${pkgs.dasel}/bin/dasel put -f ${cfg.jellyfin.configDir}/system.xml -r xml '.ServerConfiguration.EnableMetrics' -v true
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      User = cfg.jellyfin.user;
      Group = cfg.jellyfin.group;
    };
  };

  # systemd.tmpfiles.settings.jellyseerrOverride = {
  #   "${cfg.jellyseerr.configDir}/settings.json".C = {
  #     user = config.users.users.nobody.name;
  #     group = config.users.groups.nogroup.name;
  #     mode = "0644";
  #     argument = ./settings.json; # TODO: sops template
  #   };
  # };

  systemd.tmpfiles.settings.mediaSrv = {
    "/srv/movie".L.argument = "/mnt/mie/movie";
    "/mnt/mie/movie".d = {
      inherit (cfg.jellyfin) user;
      group = "users";
      mode = "0775";
    };

    "/srv/radarr".L.argument = "/mnt/mie/radarr";
    "/mnt/mie/radarr".d = {
      inherit (cfg.radarr) user;
      group = "users";
      mode = "0775";
    };

    "/srv/torrent".L.argument = "/mnt/mie/torrent";
    "/mnt/mie/torrent".d = {
      inherit (cfg.transmission) user;
      group = "users";
      mode = "0775";
    };
    # temporarily mkdir manually, dunno way not working
    # "/mnt/mie/torrent/radarr".d = {
    #   inherit (cfg.radarr) user;
    #   group = "users";
    #   mode = "0775";
    # };
  };

  systemd.services = {
    jellyfin.environment =
      lib.mkIf cfg.jellyfin.enable {
        JELLYFIN_PublishedServerUrl = "https://${subdomain}.${cfg.cloudflared'.domain}";
      }
      // proxyEnv;
  };

  preservation.preserveAt."/persist" = {
    directories = [
      (lib.mkIf cfg.jellyfin.enable {
        directory = cfg.jellyfin.dataDir;
        inherit (tmpfilesSettings.jellyfinDirs.${cfg.jellyfin.dataDir}.d)
          user
          group
          mode
          ;
      })
      # permission issue
      # (lib.mkIf cfg.jellyseerr.enable {
      #   directory = "/var/lib/${
      #     if systemdServices.jellyseerr.serviceConfig.DynamicUser then "private/" else ""
      #   }${systemdServices.jellyseerr.serviceConfig.StateDirectory}";
      #   user = users.nobody.name;
      #   group = groups.nogroup.name;
      #   mode = "0755";
      # })
      (lib.mkIf cfg.radarr.enable {
        directory = cfg.radarr.dataDir;
        inherit (tmpfilesSettings."10-radarr".${cfg.radarr.dataDir}.d)
          user
          group
          mode
          ;
      })
      (lib.mkIf cfg.transmission.settings.incomplete-dir-enabled {
        directory = cfg.transmission.settings.incomplete-dir;
        inherit (cfg.transmission) user group;
        mode =
          if builtins.isNull cfg.transmission.downloadDirPermissions then
            "0775"
          else
            cfg.transmission.downloadDirPermissions;
      })
      (lib.mkIf cfg.bazarr.enable {
        directory = "/var/lib/${config.systemd.services.bazarr.serviceConfig.StateDirectory}";
        inherit (cfg.bazarr) user group;
        mode = "0775";
      })
    ];
  };

  systemd.timers."update-transmission-trackers" = lib.mkIf cfg.transmission.enable {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "update-transmission-trackers.service";
    };
  };
  systemd.services."update-transmission-trackers" =
    let
      updater = pkgs.writeShellApplication {
        name = "update-transmission-trackers";

        runtimeInputs = [
          pkgs.curl
          pkgs.gawk
          pkgs.gnugrep
          cfg.transmission.package
        ];

        text = ''
          trackers_url="https://ngosang.github.io/trackerslist/trackers_best.txt"
          trackers_file="/tmp/trackers_best.txt"

          echo -e "\e[0;36mDownloading trackerslist: \e[4;36m$trackers_url\e[0m"

          curl -s -o "$trackers_file" "$trackers_url"

          echo -e "\e[0;32mDownloaded: $trackers_file\e[0m"

          trackers=$(awk -v RS="\n\n" '{print $0}' "$trackers_file")

          task_ids=$(transmission-remote --list | awk 'NR>1 {print $1}' | head -n-1)

          for id in $task_ids; do
            old_tracker_ids=$(transmission-remote -t "$id" -it | grep -oP 'Tracker \K\d+')
            for tracker_id in $old_tracker_ids; do
              echo -e "\e[0;36mRemoving tracker \e[1;36m$tracker_id\e[0;36m for task ID: \e[4;36m$id\e[0m"
              transmission-remote -t "$id" --tracker-remove "$tracker_id" || \
              echo -e "\e[0;31mFailed to remove tracker \e[1;36m$tracker_id\e[0;31m for task ID: \e[1;31m$id\e[0m"
            done
            for tracker in $trackers; do
              echo -e "\e[0;36mAdding tracker \e[4;36m$tracker\e[0;36m for task ID: \e[1;36m$id\e[0m"
              transmission-remote -t "$id" --tracker-add "$tracker" || \
              echo -e "\e[0;31mFailed to add tracker \e[4;31m$tracker\e[0;31m for task ID: \e[1;31m$id\e[0m"
            done
          done

          echo -e "\e[0;32mAll trackers have been updated! 🎉\e[0m"
        '';
      };
    in
    lib.mkIf cfg.transmission.enable {
      serviceConfig = {
        Type = "oneshot";
        User = config.users.users.transmission.name;
        ExecStart = lib.getExe updater;
      };
    };
}
