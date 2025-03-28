{
  description = "A startup rust project with devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devshell.flakeModule ];

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (import inputs.rust-overlay)
            ];
          };
          devshells.default =
            let
              # rust-toolchain = (pkgs.rust-bin.fromRustupToolchainFile ../rust-toolchain.toml).override {
              #   extensions = [
              #     "rust-src"
              #     "rust-analyzer"
              #   ];
              # };
              rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
                extensions = [
                  "rust-src"
                  "rust-analyzer"
                ];
              };
            in
            {
              imports = [ "${inputs.devshell}/extra/language/c.nix" ];
              packages = [ rust-toolchain ];
              language.c.includes = [ ];
            };
        };

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
}
