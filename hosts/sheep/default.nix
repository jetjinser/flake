{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
