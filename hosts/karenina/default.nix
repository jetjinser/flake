{ inputs
, ...
}:

let
  installer =
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi-installer.nix";
in

{
  imports = [
    installer

    ./configuration.nix

    ../share/cloud
  ];

  nixpkgs.localSystem.system = "aarch64-linux";
}
