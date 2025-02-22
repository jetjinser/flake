{
  pkgs,
  lib,
  ...
}:

let
  nix-about = with pkgs; [
    # keep-sorted start
    nil
    nix-output-monitor
    nixfmt-rfc-style
    # keep-sorted end
  ];
  util = with pkgs; [
    # keep-sorted start
    lsof
    screen
    wakatime
    # keep-sorted end
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
    ripgrep.enable = true;
    bat = {
      enable = true;
      config.theme = "ansi";
    };
    tmux = {
      enable = true;
      clock24 = true;
      shortcut = "\\\\";
      shell = "${lib.getExe pkgs.fish}";
      terminal = "screen-256color";
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = dracula;
          extraConfig = ''
            set -g @dracula-plugins "cpu-usage ram-usage battery time"

            set -g @dracula-show-battery true
            set -g @dracula-show-powerline false
            set -g @dracula-show-left-icon λ

            set -g @dracula-cpu-usage-label "CPU"
            set -g @dracula-ram-usage-label "RAM"
          '';
        }
      ];
      extraConfig = builtins.readFile ../../config/tmux/tmux.conf;
    };

    man = {
      enable = true;
      generateCaches = true;
    };
  };
}
