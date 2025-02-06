{
  flake,
  ...
}:

{
  imports = [
    flake.inputs.sops-nix.homeManagerModules.sops
    ./sops.nix
    ./proxy.nix
    ./ssh.nix
    ./wezterm.nix

    ./extra.nix
  ];
}
