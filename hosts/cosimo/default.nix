{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ./user.nix
    ./ssh.nix
    ./services
    ./sops.nix
  ];

  nix.channel.enable = false;
}
