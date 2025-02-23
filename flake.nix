{
  description = "NixOS & Darwin configuration de jinser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    # a light flake module
    nixos-flake.url = "github:srid/nixos-flake";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.flake-compat.follows = "flake-compat";
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
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    preservation.url = "github:WilliButz/preservation";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Windows Manager
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    niri.url = "github:sodiboo/niri-flake";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    simple-nixos-mailserver.url = "gitlab:simple-nixos-mailserver/nixos-mailserver/master";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    attic.url = "github:zhaofengli/attic";
    pico = {
      url = "github:jetjinser/pico/nixify";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
      };
    };
    quasique = {
      url = "github:jetjinser/quasique";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    nonebot2 = {
      # url = "github:jetjinser/nonebot2.nix";
      url = "git+file:///home/jinser/vie/projet/im-qq/nonebot2.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        devshell.follows = "devshell";
      };
    };

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templates.url = "github:nixos/templates";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # declared options.{nixos, darwin}Modules(_)+
        inputs.nixos-flake.flakeModule

        ./flakeModules

        ./symbols
        ./lib
        ./malib
        ./modules

        ./troisModules
      ];

      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];

      flake =
        let
          systems = import ./systems self.nixos-flake.lib;
        in
        {
          darwinConfigurations = systems.allDarwin;

          nixosConfigurations = systems.allNixOS;

          deploy.nodes = systems.mkAllNodes inputs.deploy-rs.lib;

          templates = inputs.templates.templates // import ./templates;
        };
    };
}
