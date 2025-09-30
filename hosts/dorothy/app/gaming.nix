{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  enable = false;

  inherit (flake.config.symbols.people) myself;
  cfg = config.programs.steam;
in
{
  imports = [ flake.config.modules.nixos.misc ];

  programs.steam = {
    inherit enable;
    package = pkgs.steam.override {
      extraEnv.DISPLAY = ":0";
    };
    gamescopeSession.enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  preservation.preserveAt."/persist" = lib.mkIf cfg.enable {
    users.${myself}.directories = [ ".local/share/Steam" ];
  };

  nixpkgs.superConfig.allowUnfreeList = lib.mkIf cfg.enable [
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
}
