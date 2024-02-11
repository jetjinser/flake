{ self, lib, inputs, ... }:

{
  nix = {
    registry =
      (lib.mapAttrs (_: value: { flake = value; }) inputs) // {
        templates.flake = self;
      };

    settings = {
      experimental-features = "nix-command flakes";
      substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
    };

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 0; Minute = 0; };
      options = "--delete-older-than 14d";
    };
  };
}
