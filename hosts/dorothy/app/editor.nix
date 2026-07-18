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
    lib,
    pkgs,
    config,
    ...
  }:
  let
    cfg = config.programs.emacs;

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
      inherit (cfg) enable;
      client.enable = true;
      socketActivation.enable = true;
    };
    programs.emacs = {
      enable = false;
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

          markdown-mode

          treesit-grammars.with-all-grammars
          treesit-auto
          treesit-fold
        ];
    };
    home.packages = lib.mkIf cfg.enable [
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
