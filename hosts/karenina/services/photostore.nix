{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;

  autoAlbums = cfg.immich.enable && cfg.transmission.enable;
  storePath = cfg.transmission.settings.download-dir;
in
{
  services.immich = {
    enable = true;
    port = 9002;
    host = "0.0.0.0";
    openFirewall = true;
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };

  sops.secrets = {
    immichAPIKeyForAutoAlbum.owner = cfg.immich.user;
  };
  systemd.timers."immich-folder-album-creator" = lib.mkIf autoAlbums {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "immich-folder-album-creator.service";
    };
  };
  systemd.services."immich-folder-album-creator" =
    let
      version = "0.18.2";
      src = pkgs.fetchFromGitHub {
        owner = "Salvoxia";
        repo = "immich-folder-album-creator";
        rev = version;
        hash = "sha256-cIJwVOMKLeE67VssQa+WKmqGpDeIr7wVLtoci/slIPQ=";
      };
      python = pkgs.python3.withPackages (
        ps: with ps; [
          requests
          urllib3
          pyyaml
          regex
        ]
      );
      immich-folder-album-creator = pkgs.writeShellApplication {
        name = "immich-folder-album-creator";
        runtimeInputs = [ python ];
        text = ''
          python ${src}/immich_auto_album.py \
            --unattended \
            --api-key-type file \
            ${storePath} \
            http://localhost:${toString cfg.immich.port}/api \
            ${secrets.immichAPIKeyForAutoAlbum.path}
        '';
      };
    in
    lib.mkIf (cfg.immich.enable && cfg.transmission.enable) {
      serviceConfig = {
        Type = "oneshot";
        User = cfg.immich.user;
        ExecStart = lib.getExe immich-folder-album-creator;
      };
    };
}
