{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ../cosimo/user.nix
    ../cosimo/ssh.nix
  ];

  nix.channel.enable = false;
}
