{ nix-darwin
, home-manager
, system
, specialArgs
, darwinModules
, homeModules
, overlays ? [ ]
}:

let
  inherit (specialArgs) username;
in

nix-darwin.lib.darwinSystem {
  inherit system specialArgs;

  modules =
    darwinModules
    ++ [
      home-manager.darwinModules.home-manager
      {
        nixpkgs.overlays = overlays;

        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;

        home-manager.extraSpecialArgs = specialArgs;
        home-manager.users.${username} = homeModules;
      }
    ];
}
