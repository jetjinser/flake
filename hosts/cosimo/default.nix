{
  imports = [
    ./configuration.nix
    ./disk-config.nix

    ./user.nix
    ./ssh.nix
  ];

  nix.channel.enable = false;
}
