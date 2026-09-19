{
  programs.firefox = {
    enable = true;
    # keep legacy profile path (home.stateVersion < 26.05 default);
    # dorothy already migrated to the XDG path explicitly.
    configPath = ".mozilla/firefox";
  };
}
