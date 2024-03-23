{ config
, lib
, pkgs
, flake
, ...
}:

let
  cfg = config.servicy.sing-box;
  inherit (config.home) homeDirectory;
  settingsFormat = pkgs.formats.json { };

  inherit (flake.config.malib pkgs) genJqSecretsReplacementSnippet;
in
{
  options = {
    servicy.sing-box = {
      enable = lib.mkEnableOption (lib.mdDoc "sing-box universal proxy platform");

      package = lib.mkPackageOption pkgs "sing-box" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
          options = {
            route = {
              geoip.path = lib.mkOption {
                type = lib.types.path;
                default = "${pkgs.sing-geoip}/share/sing-box/geoip.db";
                defaultText = lib.literalExpression "\${pkgs.sing-geoip}/share/sing-box/geoip.db";
                description = lib.mdDoc ''
                  The path to the sing-geoip database.
                '';
              };
              geosite.path = lib.mkOption {
                type = lib.types.path;
                default = "${pkgs.sing-geosite}/share/sing-box/geosite.db";
                defaultText = lib.literalExpression "\${pkgs.sing-geosite}/share/sing-box/geosite.db";
                description = lib.mdDoc ''
                  The path to the sing-geosite database.
                '';
              };
            };
          };
        };
        default = { };
        description = lib.mdDoc ''
          The sing-box configuration, see https://sing-box.sagernet.org/configuration/ for documentation.

          Options containing secret data should be set to an attribute set
          containing the attribute `_secret` - a string pointing to a file
          containing the value the option should be set to.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    launchd = {
      enable = true;
      agents.sing-box =
        let
          script = ''
            # f**k launchd
            sleep 10;

            mkdir -p ${homeDirectory}/.config/sing-box
            ${genJqSecretsReplacementSnippet cfg.settings "${homeDirectory}/.config/sing-box/config.json"}

            ${lib.getExe cfg.package} -D /var/lib/sing-box -C ${homeDirectory}/.config/sing-box run
          '';
        in
        {
          enable = true;
          config = {
            Program = toString (pkgs.writeShellScript "sing-box-wrapper" script);
            Label = "org.sagernet.sing-box";
            KeepAlive = true;
            RunAtLoad = true;
            StandardOutPath = "${homeDirectory}/.cache/sing-box/sing-box.log";
            StandardErrorPath = "${homeDirectory}/.cache/sing-box/sing-box-error.log";
            RestartInterval = 10;
            LimitNOFILE = 65536;
            Umask = 63;
          };
        };
    };
  };
}
