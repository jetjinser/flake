{
  description = "A startup Haskell project with devshell";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem = { pkgs, ... }: {
        devshells.default =
          let
            hpkgs = with pkgs.haskellPackages; [
              ghc
              cabal-install
              haskell-language-server
            ];
          in
          {
            env = [ ];
            commands = [ ];
            packages = hpkgs ++ (with pkgs; [
              stylish-haskell
            ]);
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

