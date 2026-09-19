{
  pkgs,
  lib,
  flake,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (flake) inputs;
in
{
  # NOTE: system.extraDependencies lives in nixosModules.common
  # (it is provided by nixos-flake's nixos module; nix-darwin
  # has no such option).
  nix = {
    channel.enable = false;
    registry = (lib.mapAttrs (_: value: { flake = value; }) flake.inputs) // {
      # shorthand for `nixpkgs`
      self.flake = flake.self;
      p.flake = flake.inputs.nixpkgs;
    };

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        # "https://mirrors.cernet.edu.cn/nix-channels/store"
        # "https://mirrors.ustc.edu.cn/nix-channels/store/"
        # down: Fri Feb 14 12:47:20 AM CST 2025
        # "https://mirror.sjtu.edu.cn/nix-channels/store"
      ];
      nix-path = lib.mkForce "nixpkgs=${inputs.nixpkgs}";
      use-xdg-base-directories = true;
      trusted-public-keys = [ ];
      builders-use-substitutes = true;
      trusted-users = [
        "root"
        "jinser"
        "@wheel"
      ];
      allowed-users = [ "@users" ];
      download-buffer-size = 67108864 * 2; # 64 mebibytes (default) * 2
    };

    gc = {
      automatic = lib.mkDefault true;
      options = "--delete-older-than 21d";
    }
    // (
      if isDarwin then
        {
          interval = {
            Weekday = 0;
            Hour = 5;
            Minute = 30;
          };
        }
      else
        {
          dates = "Mon *-*-* 00:05:30";
        }
    );
    optimise = {
      automatic = true;
      # after GC 10 minutes
      dates = [ "Mon *-*-* 00:05:40" ];
    };
  };
}
