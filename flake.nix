{
  description = "NixOS & Darwin configuration de jinser";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    # a light flake module
    nixos-flake.url = "github:jetjinser/nixos-unified/old-nixos-flake";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    # This is only used to make other inputs follow.
    flake-utils.url = "github:numtide/flake-utils";
    systems.follows = "flake-utils/systems";
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
      inputs = {
        flake-compat.follows = "flake-compat";
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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
        systems.follows = "systems";
      };
    };

    pico = {
      url = "github:jetjinser/pico/nixify";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        devshell.follows = "devshell";
        gomod2nix.inputs.flake-utils.follows = "flake-utils";
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
        nixpkgs.follows = "nixpkgs";
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
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nvfetcher.inputs = {
          flake-compat.follows = "flake-compat";
          flake-utils.follows = "flake-utils";
        };
      };
    };

    nix-topology = {
      url = "github:oddlama/nix-topology";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    templates.url = "github:nixos/templates";

    dae = {
      url = "github:daeuniverse/flake.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };

    nix-cachyos-kernel = {
      url = "github:xddxdd/nix-cachyos-kernel/release";
      inputs = {
        flake-compat.follows = "flake-compat";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  nixConfig = {
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
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
