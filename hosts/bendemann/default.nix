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
    ./game.nix

    ../share/cloud/ssh.nix
  ];

  programs.ssh.startAgent = true;

  nix.channel.enable = false;
}
