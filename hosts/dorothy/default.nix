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

    ./desktop.nix
    ../share/cloud/user.nix
  ];

  hardware.enableRedistributableFirmware = true;

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
