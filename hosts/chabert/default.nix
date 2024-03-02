{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ../share/cloud
    ./services
    ./minecraft-server
  ];

  nix.channel.enable = false;
}
