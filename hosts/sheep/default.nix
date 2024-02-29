{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./network.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
