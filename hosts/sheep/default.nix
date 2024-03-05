{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./network.nix

    ./dev.nix

    ../share/cloud
  ];

  nix.channel.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
