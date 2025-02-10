{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  cfg = config.programs.steam;
in
{
  imports = [ flake.config.modules.nixos.misc ];

  programs.steam = {
    enable = false;
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
