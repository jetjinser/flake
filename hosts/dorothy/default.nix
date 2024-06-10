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

    ./desktop.nix
    ../share/cloud/user.nix
  ];

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
