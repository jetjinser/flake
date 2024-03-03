inputs:

let
  hostModules = [
    ./configuration.nix

    ../share

    ../../../hosts/share/cloud
  ];
in
{
  nixOSModules = [
    ../../modules/share
  ] ++ hostModules;

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
