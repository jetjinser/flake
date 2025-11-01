{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
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
    ./disko-config.nix
    ./persist.nix

    ../share/cloud/ssh.nix
  ];

  nix.channel.enable = false;

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${myself}/vie/projet/flake";
  };
  nix.gc.automatic = false;
}
