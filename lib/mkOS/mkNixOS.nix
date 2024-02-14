{ nixpkgs
, system
, specialArgs
, home-manager
, nixOSModules
, homeModules
}:

let
  inherit (specialArgs) username;
in

nixpkgs.lib.nixosSystem {
  inherit system specialArgs;

  modules =
    nixOSModules
    ++ [
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${username} = homeModules;
      }
    ];
}
