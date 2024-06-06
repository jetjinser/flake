{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.dotothy

    ./configuration.nix
    ./disko-config.nix
  ];

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
