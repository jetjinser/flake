{ flake
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

  hardware.enableRedistributableFirmware = true;

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
