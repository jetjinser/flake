inputs:

{
  nixOSModules = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    inputs.simple-nixos-mailserver.nixosModule

    ../../modules/share
    ../../hosts/cosimo
  ];

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
