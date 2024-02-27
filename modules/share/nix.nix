{ self, pkgs, lib, inputs, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
  inherit (inputs) nixpkgs;

  # const = import ../../const.nix;
  # inherit (const.machines) aliyun jdcloud;
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
      substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
      nix-path = lib.mkForce "nixpkgs=${nixpkgs}";
      # builders-use-substitutes = true;
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

    distributedBuilds = true;
    buildMachines =
      let
        protocol = "ssh-ng";
      in
      [
        {
          inherit protocol;
          hostName = "mimo";
          speedFactor = 1;
          system = "x86_64-linux";
        }
        {
          inherit protocol;
          hostName = "cher";
          speedFactor = 2;
          system = "x86_64-linux";
        }
      ];
  };
}
