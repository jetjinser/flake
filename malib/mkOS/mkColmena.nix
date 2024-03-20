{ deployment
, specialArgs
, home-manager
, nixOSModules
, homeModules
, overlays ? [ ]
, ...
}:

let
  inherit (specialArgs) username;
in

{
  inherit deployment;

  imports =
    nixOSModules
    ++ [
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = overlays;

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${username} = homeModules;
      }
    ];
}
