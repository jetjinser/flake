{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.servicy.haste-server;
in
{
  options.servicy.haste-server = {
    enable = lib.mkEnableOption "Whether to enable haste server";
  };

  config = lib.mkIf cfg.enable (
    let
      pod = "haste";
    in
    {
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            redis = {
              image = "redis:alpine";
              # ports = [ "8287:8287" ];
              cmd = [
                "redis-server"
                "--port 8287"
                "--requirepass redis"
              ];
              # hostname = "redis";
              extraOptions = [ "--pod=${pod}" ];
            };
            haste = {
              image = "ghcr.io/skyra-project/haste-server:latest";
              # ports = [ "8290:8290" ];
              dependsOn = [ "redis" ];
              environment = {
                PORT = "8290";
                STORAGE_TYPE = "redis";
                STORAGE_HOST = "redis";
                STORAGE_PORT = "8287";
                STORAGE_PASSWORD = "redis";
                STORAGE_DB = "2";
                STORAGE_EXPIRE_SECONDS = "2147483647";
              };
              extraOptions = [ "--pod=${pod}" ];
            };
          };
        };
      };

      systemd.services."create-${pod}-pod" = with config.virtualisation.oci-containers; {
        serviceConfig.Type = "oneshot";
        wantedBy = [ "${backend}-haste.service" ];
        script = ''
          ${pkgs.podman}/bin/podman pod exists ${pod} || \
            ${pkgs.podman}/bin/podman pod create -n ${pod} -p '127.0.0.1:8290:8290'
        '';
      };
    }
  );
}
