{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.fish.shellAbbrs = {
    cdf = "cd ~/vie/projet/flake";
    cdw = "cd ~/vie/writing/forest";
  };
}
