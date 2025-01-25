{
  description = "A startup python project with devshell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        # devshell
        {
          perSystem = { pkgs, ... }: {
            devshells.default = {
              env = [ ];
              commands = [ ];
              packages = with pkgs;[
                (python3.withPackages (ps: with ps; [
                  requests
                ]))
              ];
            };
          };
        }
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    };
}
