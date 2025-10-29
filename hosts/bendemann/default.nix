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
    ./desktop

    ../share/cloud/ssh.nix
  ];

  nix.channel.enable = false;
}
