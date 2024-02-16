{ lib, config, ... }:

let
  cfg = config.servicy.haste-server;
in
{
  options.servicy.haste-server = {
    enable = lib.mkEnableOption "Wether to enable haste server";
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      oci-containers = {
        backend = "podman";
        containers = {
          redis = {
            image = "redis:alpine";
            ports = [ "8287:8287" ];
            cmd = [
              "redis-server"
              "--port 8287"
              "--requirepass redis"
            ];
            hostname = "redis";
          };
          haste = {
            image = "ghcr.nju.edu.cn/skyra-project/haste-server:latest";
            ports = [ "8290:8290" ];
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
          };
        };
      };
    };
  };
}
