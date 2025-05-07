{
  description = "A startup Guile project with devshell";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        {
          devshells.default = {
            packages = with pkgs; [
              guile
            ];
            env = [
              {
                name = "GUILE_LOAD_PATH";
                prefix = "$DEVSHELL_DIR/${pkgs.guile.siteDir}";
              }
            ];
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
