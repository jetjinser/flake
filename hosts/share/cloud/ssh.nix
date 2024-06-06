{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users =
    let
      ssh-keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILkVlWmF+kMCPIdWkvDsXFHDtq84njf8NVN7GxUCAHs julien@darwin" ];
    in
    {
      jinser.openssh.authorizedKeys.keys = ssh-keys;
      root.openssh.authorizedKeys.keys = ssh-keys;
    };
}
