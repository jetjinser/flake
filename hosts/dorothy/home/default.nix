{
  imports = [
    ./browser.nix
    ./terminal.nix
    ./im.nix
    ./ssh.nix
    ./niri.nix
    # ./xdg-conf.nix
    # ./dev.nix
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
