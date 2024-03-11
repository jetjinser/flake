{ username
, pkgs
, ...
}:

{
  imports = [
    ./sys_config.nix
    ./homebrew.nix
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs.zsh.enable = true;
  programs.fish.enable = true;
  users.users.${username} = {
    home = "/Users/jinserkakfa";
    shell = pkgs.fish;
  };
}
