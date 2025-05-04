{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    ...
  }:
  {
    services.emacs = {
      enable = true;
      client.enable = true;
      socketActivation.enable = true;
    };
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
    };
  }
)
// {
  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".config/emacs"
    ];
  };
}
