inputs:

{
  nixOSModules = [
    ../../modules/share
    ../../hosts/chabert
  ];

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
