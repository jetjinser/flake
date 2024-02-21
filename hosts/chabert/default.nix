{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ../share/cloud
    ./minecraft-server
  ];

  nix.channel.enable = false;
}
