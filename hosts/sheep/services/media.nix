{ flake
, config
, pkgs
, lib
, ...
}:

# TODO:
# - metrics
# - PostgreSQL
# - declarative config ASAP
# - maybe some distributed storage
# - unify user & group

let
  inherit (flake.config.symbols.people) myself;

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
    jellyseerr.enable = true;
    # https://github.com/NixOS/nixpkgs/issues/360592
    # wait for v5 that bump dotnet to 8
    # sonarr.enable = true;
    radarr.enable = true;
    prowlarr.enable = true;
    # bazarr subtitles

    transmission = {
      enable = true;
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
    discovery = cfg.jellyseerr.port;
    "radarr" = 7878;
    "prowlarr" = 9696;
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

  systemd.services.jellyfin.environment = {
    JELLYFIN_PublishedServerUrl = "https://${subdomain}.${cfg.cloudflared'.domain}";
  } // proxyEnv;
  systemd.services.jellyseerr.environment = proxyEnv;

  preservation.preserveAt."/persist" = {
    directories = [
      {
        directory = cfg.jellyfin.dataDir;
        inherit (tmpfilesSettings.jellyfinDirs.${cfg.jellyfin.dataDir}.d)
          user group mode;
      }
      {
        directory = cfg.radarr.dataDir;
        inherit (tmpfilesSettings."10-radarr".${cfg.radarr.dataDir}.d)
          user group mode;
      }
      (lib.mkIf cfg.transmission.settings.incomplete-dir-enabled {
        directory = cfg.transmission.settings.incomplete-dir;
        inherit (cfg.transmission) user group;
        mode =
          if builtins.isNull cfg.transmission.downloadDirPermissions
          then "0775" else cfg.transmission.downloadDirPermissions;
      })
    ];
  };
}
