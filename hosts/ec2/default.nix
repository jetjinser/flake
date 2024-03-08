{ inputs
, ...
}:

{
  imports = [
    inputs.nixos-generators.nixosModules.all-formats

    ({ lib, ... }: {
      nix = {
        settings = {
          substituters = lib.mkForce [ ];
        };
      };
    })
    {
      formatConfigs.amazon = { config, ... }: {
        amazonImage.sizeMB = 16 * 1024;
      };
    }

    ./configuration.nix
    ./disko-config.nix

    ./dev.nix
    ./mosh.nix

    ../share/cloud
  ];

  nix.channel.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
