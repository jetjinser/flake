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
  };
}
