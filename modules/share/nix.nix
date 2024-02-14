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
      substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
      nix-path = lib.mkForce "nixpkgs=${nixpkgs}";
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
  };
}
