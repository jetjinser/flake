{
  imports = [
    ./configuration.nix
    ./disk-config.nix

    ./user.nix
  ];

  nix.channel.enable = false;
}
