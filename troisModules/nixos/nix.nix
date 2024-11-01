{ pkgs
, lib
, flake
, ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (flake.inputs) nixpkgs;
in
{
  # environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";

  nix = {
    # use latest nix CLI
    # regression bug: https://github.com/NixOS/nix/issues/11681
    package = pkgs.nixVersions.nix_2_18;
    registry =
      (lib.mapAttrs (_: value: { flake = value; }) flake.inputs) // {
        templates.flake = flake.self;
      };

    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://mirrors.cernet.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        # "https://hyprland.cachix.org"
        # "https://nix-community.cachix.org?priority=41"
      ];
      nix-path = lib.mkForce "nixpkgs=${nixpkgs}";
      use-xdg-base-directories = true;
      trusted-public-keys = [
        # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      # builders-use-substitutes = true;
      trusted-users = [
        "root"
        "jinser"
        "@wheel"
        "@admin"
      ];
    };

    gc = {
      automatic = lib.mkDefault true;
      options = "--delete-older-than 7d";
    } // (
      if isDarwin then {
        interval = { Weekday = 0; Hour = 0; Minute = 0; };
      } else {
        dates = "weekly";
      }
    );

    # envVars.GOPROXY = "https://goproxy.cn,direct";

    distributedBuilds = false;
    buildMachines =
      let
        protocol = "ssh-ng";
      in
      [
        {
          inherit protocol;
          hostName = "cosimo";
          speedFactor = 1;
          system = "x86_64-linux";
        }
        {
          inherit protocol;
          hostName = "chabert";
          speedFactor = 2;
          system = "x86_64-linux";
        }
      ];
  };
}
