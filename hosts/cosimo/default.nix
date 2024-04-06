{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.cosimo

    ./configuration.nix
    ./disko-config.nix

    ./sops.nix
    ./services
    ./network.nix

    ../share/cloud
  ];

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
