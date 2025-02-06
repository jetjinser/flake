{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkPackageOption
    mkOption
    mkIf
    ;

  cfg = config.programs.raffi;

  yamlFormat = pkgs.formats.yaml { };
in
{
  options.programs.raffi = {
    enable = mkEnableOption "raffi";
    package = mkPackageOption pkgs "raffi" { };

    settings = mkOption {
      inherit (yamlFormat) type;
      default = { };
      example =
        # yaml
        literalExpression ''
          firefox:
            binary: firefox
            args: [--marionette]
            icon: firefox
            description: Firefox browser with marionette enabled
        '';
      description = ''
        Configuration for Raffi written to
        {file}`$XDG_CONFIG_HOME/raffi/raffi.yaml`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."raffi/raffi.yaml" = mkIf (cfg.settings != { }) {
      source = yamlFormat.generate "raffi.yaml" cfg.settings;
    };
  };
}
