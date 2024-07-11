{ pkgs
, flake
, ...
}:

{
  imports = [
    # ../../troisModules/darwin/default.nix
    flake.inputs.self.darwinModules.julien
    ./homebrew.nix
    ./system.nix

    ./network.nix
  ];

  nixpkgs = {
    hostPlatform = "x86_64-darwin";
  };

  security.pam.enableSudoTouchIdAuth = true;

  environment.variables = {
    EDITOR = "nvim";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  programs = {
    zsh.enable = true;
    fish.enable = true;
  };

  users.users =
    let
      inherit (flake.config.symbols.people) myself;
    in
    {
      ${myself} = {
        name = myself;
        home = "/Users/${myself}";
        shell = pkgs.fish;
      };
    };
}
