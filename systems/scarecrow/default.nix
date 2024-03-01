inputs:

let
  hostModules = [
    ./configuration.nix
    ./network.nix

    ../../hosts/share/cloud
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
