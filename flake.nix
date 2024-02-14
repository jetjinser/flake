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

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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

      flake =
        let
          mkOS = import ./lib/mkOS { inherit self inputs; };
        in
        {
          darwinConfigurations = mkOS.allDarwin;

          nixosConfigurations = mkOS.allNixOS;

          templates = inputs.templates.templates // import ./templates;

          colmena = {
            meta = {
              nixpkgs = import nixpkgs {
                system = "x86_64-linux";
              };
              nodeSpecialArgs = {
                cosmino = {
                  inherit inputs self;
                };
              };
            };

            cosmino = {
              deployment = {
                targetHost = "106.14.161.118";
                targetPort = 22;
                targetUser = "root";
                buildOnTarget = true;
              };
              imports = [
                inputs.disko.nixosModules.disko
                inputs.nix-index-database.hmModules.nix-index

                inputs.home-manager.nixosModules.home-manager
                (
                  let
                    stateVersion = "24.05";
                  in
                  {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;

                    home-manager.users.jinser = { ... }: {
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
            };
          };
        };
    };
}
