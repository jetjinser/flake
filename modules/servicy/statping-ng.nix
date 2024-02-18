{ lib, config, ... }:

let
  cfg = config.servicy.statping-ng;
in
{
  options.servicy.statping-ng = {
    enable = lib.mkEnableOption "Whether to enable statping-ng";
  };

  config = lib.mkIf cfg.enable {
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            statping-ng = {
              image = "adamboutcher/statping-ng";
              ports = [ "8991:8080" ];
            };
          };
        };
      };
    };
}
