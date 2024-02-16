{
  imports = [
    ./configuration.nix
    ./disko-config.nix

    ./user.nix
    ./ssh.nix
    ./services.nix
    ./sops.nix
  ];

  nix.channel.enable = false;
}
