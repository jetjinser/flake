{ pkgs
, ...
}:

let
  nix-about = with pkgs; [
    nixpkgs-fmt
    nix-output-monitor
    nil

    cachix
  ];
  util = with pkgs; [
    numbat
    screen
    lsof
  ];
in
{
  home.packages = nix-about ++ util;

  programs = {
    direnv.enable = true;
    neovim = {
      enable = true;
      package = pkgs.neovim-nightly;
      defaultEditor = true;
    };
    ripgrep.enable = true;
    bat = {
      enable = true;
      config = {
        theme = "ansi";
      };
    };

    tmux = {
      enable = true;
      terminal = "xterm-256color";
    };

    man = {
      enable = true;
      generateCaches = true;
    };
  };
}
