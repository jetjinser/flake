{
  imports = [
    # inputs.nixos-generators.nixosModules.all-formats

    ({ lib, ... }: {
      nix = {
        settings = {
          substituters = lib.mkForce [
            "https://cache.nixos.org/"
          ];
        };
      };
    })
    # {
    #   formatConfigs.amazon = { config, ... }: {
    #     amazonImage.sizeMB = 16 * 1024;
    #   };
    # }

    ./configuration.nix
    ./disko-config.nix

    ./dev.nix
    ./mosh.nix

    ../share/cloud
  ];

  nix.channel.enable = false;

  # INFO: I dunno why: https://github.com/NixOS/nixpkgs/issues/259352
  # services.nscd.enable = false;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
