inputs:

{
  nixOSModules = [
    ({ lib, ... }: {
      nix = {
        settings = {
          substituters = lib.mkForce [
            "https://cache.nixos.org/"
          ];
        };
      };
    })

    ../../modules/share
    ../../hosts/ec2
  ];

  homeModules = { ... }: {
    imports = [
      inputs.nix-index-database.hmModules.nix-index

      ../../homeModules/base.nix
      ../../homeModules/share
    ];
  };
}
