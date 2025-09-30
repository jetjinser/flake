{
  flake,
  config,
  ...
}:

let
  inherit (config.sops) secrets;

  inherit (flake.config.symbols.people) myself;
  inherit (config.users) users;

  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    lib,
    config,
    ...
  }:

  let
    flakeRoot = ../../../.;
    base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));

    cfg = config.programs.btop;
    rose-pine-btop = pkgs.fetchFromGitHub {
      owner = "rose-pine";
      repo = "btop";
      rev = "6d6abdc";
      hash = "sha256-sShQYfsyR5mq/e+pjeIsFzVZv3tCpQEdGC9bnTKlQ5c=";
    };
    rose-pine-btop-plain = pkgs.runCommandLocal "plain-rose-pine" { } ''
      cat ${rose-pine-btop}/rose-pine.theme > $out
    '';
    btop-desktop-with-app-id = pkgs.runCommandLocal "btop-desktop-with-app-id" { } ''
      mkdir -p $out/share/applications
      cat ${cfg.package}/share/applications/btop.desktop > $out/share/applications/btop.desktop

      sed -i 's/Terminal=true/Terminal=false/'                 $out/share/applications/btop.desktop
      sed -i 's/Exec=btop/Exec=footclient --app-id btop btop/' $out/share/applications/btop.desktop
    '';
  in
  {
    home.packages = [
      base
      (lib.hiPrio btop-desktop-with-app-id)
      pkgs.claude-code
    ];

    programs.btop = {
      enable = true;
      package = pkgs.btop-rocm;
      settings.color_theme = "rose-pine";
      themes.rose-pine = rose-pine-btop-plain;
    };

    programs.git = {
      extraConfig.sendemail = {
        smtpServer = "smtp.gmail.com";
        smtpServerPort = 587;
        smtpEncryption = "tls";
        smtpUser = "cmdr.jv@gmail.com";
      };
    };
  }
)
// {
  imports = [ flake.config.modules.nixos.misc ];
  nixpkgs.superConfig.allowUnfreeList = [ "claude-code" ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ ".radicle" ];
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${myself}/vie/projet/flake";
  };
  nix.gc.automatic = false;
}
