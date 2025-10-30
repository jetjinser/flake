{
  pkgs,
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
    wakatime-cli
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
    fd.enable = true;
    bat = {
      enable = true;
      config.theme = "ansi";
    };

    man = {
      enable = true;
      generateCaches = true;
    };
  };
}
