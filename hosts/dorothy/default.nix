{ flake
, lib
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.dorothy

    ./configuration.nix
    ./disko-config.nix
    ./persist.nix
    ./sops.nix
    ./keyboard.nix
    ./proxy.nix
    ./unfree.nix
    ./font.nix
    ./ime.nix
    # ./music.nix
    ./app.nix

    ./guix.nix
    ./dev

    ./desktop
    ../share/cloud/user.nix
  ];

  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  # https://github.com/NixOS/nixpkgs/issues/319809
  sound.enable = lib.mkForce false;

  nix.channel.enable = false;
}
