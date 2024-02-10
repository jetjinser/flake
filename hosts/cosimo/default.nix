{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ./user.nix
    ./ssh.nix
  ];

  nix.channel.enable = false;
}
