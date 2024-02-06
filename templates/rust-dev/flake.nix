{
  description = "A startup rust project with devshell";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        # rust-overlay
        {
          perSystem = { pkgs, system, ... }: {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                (import inputs.rust-overlay)
              ];
            };
          };
        }
        # devshell
        {
          perSystem = { pkgs, ... }: {
            devshells.default = {
              env = [ ];

              commands = [ ];

              packages = with pkgs; [
                pkgsBuildHost.rust-bin.stable.latest.default
              ];
            };
          };
        }
      ];

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

      perSystem = _: { };
    };
}
