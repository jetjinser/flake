{ self, pkgs, lib, inputs, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (inputs) nixpkgs;
in
{
  # environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";

  nix = {
    registry =
      (lib.mapAttrs (_: value: { flake = value; }) inputs) // {
        templates.flake = self;
      };

    settings = {
      experimental-features = "nix-command flakes";
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
      ];
      nix-path = lib.mkForce "nixpkgs=${nixpkgs}";
      # builders-use-substitutes = true;
      trusted-users = [
        "root"
        "jinser"
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    } // (
      if isDarwin then {
        interval = { Weekday = 0; Hour = 0; Minute = 0; };
      } else {
        dates = "weekly";
      }
    );

    envVars.GOPROXY = "https://goproxy.cn,direct";

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
