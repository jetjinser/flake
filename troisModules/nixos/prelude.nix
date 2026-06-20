{
  pkgs,
  lib,
  flake,
  config,
  ...
}:

let
  cfg = config.customize.prelude;
in
{
  imports = [
    flake.inputs.nix-topology.nixosModules.default
  ];

  options.customize.prelude = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Whether to enable prelude.";
    };
    withGit = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = false;
      description = "Whether to include gitMinimal.";
    };

    pkgs = lib.mkOption {
      type = with lib.types; listOf package;
      default =
        (with pkgs; [
          # keep-sorted start
          curl
          file
          jq
          screen
          zuo # maybe Guile?
          # keep-sorted end
        ])
        ++ lib.optional cfg.withGit [
          pkgs.gitMinimal
        ];
      description = "Packages included.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = map lib.lowPrio (cfg.pkgs);
  };
}
