{ username, ... }: {
  home = {
    inherit username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}

