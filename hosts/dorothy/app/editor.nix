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
  let
    emacsTodo = pkgs.writeShellApplication {
      name = "emacs-todo";
      text = ''
        emacsclient --create-frame "$HOME/vie/writing/org/todo.org"
      '';
    };
    emacsTodoDesktopEntry = pkgs.makeDesktopItem {
      name = "open-todo";
      exec = "emacs-todo";
      icon = "emacs";
      comment = "Open todo.org in Emacs";
      desktopName = "Open TODO";
      categories = [ "Utility" ];
    };
  in
  {
    services.emacs = {
      enable = true;
      client.enable = true;
      socketActivation.enable = true;
    };
    programs.emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;
      extraPackages =
        epkgs: with epkgs; [
          use-package
          doom-themes
          doom-modeline
          nyan-mode
          nerd-icons
          evil

          org
          org-modern
        ];
    };
    home.packages = [
      pkgs.texmacs
      emacsTodo
      emacsTodoDesktopEntry
    ];
  }
)
// {
  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".config/emacs"
    ];
  };
}
