{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;

  cfgSteam = config.programs.steam;
  cfgPrism = true;
in
lib.mkMerge [
  {
    imports = [ flake.config.modules.nixos.misc ];
  }

  (lib.mkIf cfgPrism (
    (mkHM (
      { pkgs, ... }: {
        home.packages = [
          (pkgs.prismlauncher.override {
            jdks = [ pkgs.graalvmPackages.graalvm-ce ];
          })
        ];
      }
    ))
    // {
      preservation.preserveAt."/persist" = {
        users.${myself}.directories = [ ".local/share/PrismLauncher" ];
      };
    }
  ))

  {
    programs.steam = {
      enable = false;
      package = pkgs.steam.override {
        extraEnv.DISPLAY = ":0";
      };
      gamescopeSession.enable = true;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
    };

    preservation.preserveAt."/persist" = lib.mkIf cfgSteam.enable {
      users.${myself}.directories = [ ".local/share/Steam" ];
    };

    nixpkgs.superConfig.allowUnfreeList = lib.mkIf cfgSteam.enable [
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
    ];
  }
]
