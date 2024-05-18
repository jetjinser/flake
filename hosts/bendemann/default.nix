{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.bendemann

    ./hardware-configuration.nix
    ./configuration.nix

    ./bluetooth.nix
    ./font.nix
    ./ime.nix
    ./nvidia.nix
    ./proxy.nix
    ./keyboard.nix
  ];

  programs.ssh.startAgent = true;

  # TODO: same as julien do
  nixpkgs.overlays = [
    flake.inputs.neovim-nightly-overlay.overlay
  ];

  nix.channel.enable = false;
}
