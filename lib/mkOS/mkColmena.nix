{ deployment
, specialArgs
, home-manager
, nixOSModules
, homeModules
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
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${username} = homeModules;
      }
    ];
}
