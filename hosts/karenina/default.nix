{ ... }:

{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware.nix
    ./network.nix

    ../share/cloud
  ];
}
