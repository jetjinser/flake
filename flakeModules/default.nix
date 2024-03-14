{ inputs, ... }: {
  imports = [
    inputs.flake-root.flakeModule
    ./devshell
    ./formatter.nix
    ./overlays.nix
    ./qkgs.nix
    ./typhon.nix
    ./ci.nix
  ];
}
