inputs:

{
  darwinModules = [
    ../../modules/share
    ../../hosts/julien
  ];
  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index
      inputs.sops-nix.homeManagerModules.sops

      ../../hosts/julien/home

      ../../homeModules/base.nix
      ../../homeModules/share
      ../../homeModules/darwin
    ];
  };
}
