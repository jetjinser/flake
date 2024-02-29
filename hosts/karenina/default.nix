{ inputs
, ...
}:

let
  installer =
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix";
in

{
  imports = [
    installer

    ./configuration.nix

    ../share/cloud
  ];
}
