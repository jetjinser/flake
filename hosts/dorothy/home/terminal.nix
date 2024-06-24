{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  home.sessionPath = [
    "$HOME/.config/guix/current/bin"
  ];

  programs.fish.shellAbbrs = {
    cdf = "cd ~/vie/projet/flake";
    cdw = "cd ~/vie/writing/forest";
  };
}
