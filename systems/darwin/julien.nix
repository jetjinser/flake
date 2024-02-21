inputs:

{
  darwinModules = [
    ../../modules/share
    ../../hosts/julien
  ];
  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../homeModules/base.nix
      ../homeModules/share
      ../homeModules/darwin
    ];
  };
}
