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

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    impermanence.url = "github:nix-community/impermanence";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    attic = {
      url = "github:zhaofengli/attic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typhon = {
      url = "github:typhon-ci/typhon";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        rust-overlay.follows = "rust-overlay";
      };
    };

    templates.url = "github:nixos/templates";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , ...
    }: flake-parts.lib.mkFlake { inherit inputs; } (
      let
        systems = import ./systems { inherit self inputs nixpkgs; };
      in
      {
        imports = [
          ./flakeModules
        ];

        systems = [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-linux"
        ];

        perSystem = { pkgs, ... }: {
          packages = systems.allImages;

          typhonJobs = {
            inherit (pkgs) hello;
          };
        };

        flake = {
          darwinConfigurations = systems.allDarwin;

          nixosConfigurations = systems.allNixOS;

          colmena = systems.allColmena;

          templates = inputs.templates.templates // import ./templates;
        };
      }
    );
}
