{ pkgs, ... }:

let
  nix-about = with pkgs; [
    nixpkgs-fmt
    nix-output-monitor
    nil
  ];
  util = with pkgs; [
    numbat
    screen
  ];
in
{
  home.packages = nix-about ++ util;

  programs = {
    direnv.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
