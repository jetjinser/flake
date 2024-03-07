{ inputs
, ...
}:

{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats

    ./configuration.nix
    ./network.nix

    ./dev.nix

    ../share/cloud
  ];

  nix.channel.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
