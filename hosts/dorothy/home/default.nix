{
  imports = [
    ./terminal.nix
    ./ssh.nix
    # ./xdg-conf.nix
    # ./dev.nix
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  manual.manpages.enable = true;
}
