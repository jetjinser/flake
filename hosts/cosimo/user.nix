{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users =
    let
      ssh-keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILkVlWmF+kMCPIdWkvDsXFHDtq84njf8NVN7GxUCAHs julien@darwin" ];
    in
    {
      jinser = {
        isNormalUser = true;
        home = "/home/jinser";
        description = "Jinser Kafka";
        shell = pkgs.fish;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = ssh-keys;
      };
      root.openssh.authorizedKeys.keys = ssh-keys;
    };
}
