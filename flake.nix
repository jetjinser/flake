{
  description = "NixOS & Darwin configuration de jinser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    # a light flake module
    nixos-flake.url = "github:jetjinser/nixos-unified/old-nixos-flake";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # This is only used to make other inputs follow.
    flake-utils.url = "github:numtide/flake-utils";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
      };
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.flake-compat.follows = "flake-compat";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "flake-utils";
      };
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
    preservation.url = "github:WilliButz/preservation";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # Windows Manager
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      # SAFETY: unused input
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
      };
    };

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
      url = "github:jetjinser/nonebot2.nix";
      # url = "git+file:///home/jinser/vie/projet/im-qq/nonebot2.nix";
      inputs = {
        flake-parts.follows = "flake-parts";
        treefmt-nix.follows = "treefmt-nix";
        devshell.follows = "devshell";
      };
    };
    mathb = {
      url = "github:jetjinser/mathb/bhu";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
    berberman = {
      url = "github:berberman/flakes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    templates.url = "github:nixos/templates";

    rockchip = {
      url = "github:nabam/nixos-rockchip";
      inputs.utils.follows = "flake-utils";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://nabam-nixos-rockchip.cachix.org" ];
    extra-trusted-public-keys = [
      "nabam-nixos-rockchip.cachix.org-1:BQDltcnV8GS/G86tdvjLwLFz1WeFqSk7O9yl+DR0AVM"
    ];
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

          deploy = {
            fastConnection = true;
            nodes = systems.mkAllNodes inputs.deploy-rs.lib;
          };

          templates = inputs.templates.templates // import ./templates;
        };
    };
}
