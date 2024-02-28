inputs:

{
  nixOSModules = [
    ../../modules/share
    ../../hosts/sheep
  ];

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
