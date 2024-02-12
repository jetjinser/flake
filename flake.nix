{
  description = "NixOS & Darwin configuration de jinser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templates.url = "github:nixos/templates";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , ...
    }: flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        ./flakeModules
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" ];

      flake = {
        darwinConfigurations = {
          # MacBookPro16 intel, provided by the company
          julien =
            let
              # typo i know
              user = "jinserkakfa";
            in
            inputs.nix-darwin.lib.darwinSystem {
              system = "x86_64-darwin";
              modules =
                [
                  inputs.home-manager.darwinModules.home-manager
                  (
                    let
                      stateVersion = "24.05";
                    in
                    {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;

                      home-manager.users.${user} = { ... }: {
                        imports = [
                          ./homeModules/share
                          ./homeModules/darwin
                        ];

                        home.stateVersion = stateVersion;

                        programs.home-manager.enable = true;
                      };
                    }
                  )

                  ./modules/share
                  ./hosts/julien
                ];
              specialArgs = {
                inherit user inputs self;
              };
            };
        };

        nixosConfigurations = {
          # AliCloud VPS
          cosmino =
            let
              user = "jinser";
            in
            nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules =
                [
                  inputs.disko.nixosModules.disko

                  inputs.home-manager.nixosModules.home-manager
                  (
                    let
                      stateVersion = "24.05";
                    in
                    {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;

                      home-manager.users.${user} = { ... }: {
                        imports = [
                          ./homeModules/share
                        ];

                        home.stateVersion = stateVersion;

                        programs.home-manager.enable = true;
                      };
                    }
                  )

                  ./modules/share
                  ./hosts/cosimo
                ];
              specialArgs = {
                inherit inputs self;
              };
            };
        };

        templates = inputs.templates.templates // import ./templates;
      };
    };
}
