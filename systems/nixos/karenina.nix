inputs:

{
  nixOSModules = [
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
