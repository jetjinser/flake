{ inputs
, ...
}:

{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats

    ({ lib, ... }: {
      nix = {
        settings = {
          substituters = lib.mkForce [
            "https://cache.nixos.org/"
          ];
        };
      };
    })
    {
      formatConfigs.amazon = { config, ... }: {
        amazonImage.sizeMB = 16 * 1024;
      };
    }

    ./configuration.nix
    ./network.nix

    ./dev.nix

    ../share/cloud
  ];

  nix.channel.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
