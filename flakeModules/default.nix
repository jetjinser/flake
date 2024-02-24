{ inputs, ... }: {
  imports = [
    inputs.flake-root.flakeModule
    ./devshell
    ./formatter.nix
    ./qkgs.nix
  ];
}
