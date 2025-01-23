{ flake
, pkgs
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [ flake.config.modules.nixos.misc ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ ".local/share/Steam" ];
  };

  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraEnv.DISPLAY = ":0";
    };
    gamescopeSession.enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };

  nixpkgs.superConfig.allowUnfreeList = [
    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
}
