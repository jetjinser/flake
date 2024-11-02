{
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  users.users =
    let
      ssh-keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF0sQOE/u9FfEp45LtN1AEx/8vuHxB0BiRb4Asy2o+Yb jinser@bendemann"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIO9OWTLHeJinGsCD8JX4OBK7IwGh+st1sQC/2YHCQ5m jinser@dorothy"
      ];
    in
    {
      jinser.openssh.authorizedKeys.keys = ssh-keys;
      root.openssh.authorizedKeys.keys = ssh-keys;
    };
}
