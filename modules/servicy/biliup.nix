{ lib
, pkgs
, config
, flake
, ...
}:

let
  cfg = config.servicy.biliup;
  format = pkgs.formats.yaml { };

  inherit (flake.config.malib pkgs) genJqSecretsReplacementSnippet;
in
{
  options.servicy.biliup = {
    enable = lib.mkEnableOption "Whether to enable biliup";

    path = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/biliup";
      description = lib.mdDoc ''
        The path to the biliup workdir.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = format.type;
        options = { };
      };
      default = { };
      description = lib.mdDoc ''
        The biliup configuration, see https://github.com/biliup/biliup/tree/master/public/config.yaml.

        Options containing secret data should be set to an attribute set
        containing the attribute `_secret` - a string pointing to a file
        containing the value the option should be set to.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc "Open ports in the firewall for biliup.";
    };

    listenPort = lib.mkOption {
      type = lib.types.int;
      default = 19159;
      description = lib.mdDoc "Port for biliup to bind to.";
    };
  };

  config = lib.mkIf cfg.enable {
      virtualisation = {
        oci-containers = {
          backend = "podman";
          containers = {
            biliup = {
              image = "ghcr.nju.edu.cn/biliup/caution:master";
              ports = [ "${toString cfg.listenPort}:19159" ];
              volumes = [ "/var/lib/biliup:/opt" ];
            };
          };
        };
      };

      networking.firewall = lib.mkIf cfg.openFirewall {
        allowedTCPPorts = [ cfg.listenPort ];
      };

      system.activationScripts.mkBiliupConfig =
        lib.mkIf (!builtins.isNull cfg.path)
          (lib.stringAfter [ "var" ] ''
            mkdir -p ${cfg.path}
            ${genJqSecretsReplacementSnippet cfg.settings "${cfg.path}/config.yaml"}
          '');
    };
}
