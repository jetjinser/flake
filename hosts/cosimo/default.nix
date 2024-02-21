{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ./services
    ./sops.nix

    ../share/cloud
  ];

  nix.channel.enable = false;
}
