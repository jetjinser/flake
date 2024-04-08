{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.chabert

    ./configuration.nix
    ./disko-config.nix

    ./sops.nix
    ./network.nix

    ./services

    ../share/cloud
    # ./minecraft-server
  ];

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
