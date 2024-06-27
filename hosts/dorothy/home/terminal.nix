{ pkgs
, config
, ...
}:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  home.sessionPath = [
    # not working, due to the PATH order
    "${config.xdg.configHome}/.config/guix/current/bin"
  ];

  programs.fish.shellAbbrs = {
    cdf = "cd ~/vie/projet/flake";
    cdw = "cd ~/vie/writing/forest";
  };
}
