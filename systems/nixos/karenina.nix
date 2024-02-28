inputs:

let
  installer =
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-raspberrypi-installer.nix";
in

{
  nixOSModules = [
    installer

    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops

    ../../modules/share
    ../../hosts/karenina
  ];

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
