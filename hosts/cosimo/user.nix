{
  programs.fish.enable = true;

  users.users =
    let
      ssh-keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFAvby7R2z6jXPJHdO0Cn1vDnzcub9db9lHySncEu97 julien" ];
    in
    {
      jinser = {
        isNormalUser = true;
        home = "/home/jinser";
        description = "Jinser Kafka";
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = ssh-keys;
      };
      root.openssh.authorizedKeys.keys = ssh-keys;
    };
}
