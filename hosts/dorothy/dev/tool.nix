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
    flakeRoot = ../../../.;
    base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));

    rose-pine-btop = pkgs.fetchFromGitHub {
      owner = "rose-pine";
      repo = "btop";
      rev = "6d6abdc";
      hash = "sha256-sShQYfsyR5mq/e+pjeIsFzVZv3tCpQEdGC9bnTKlQ5c=";
    };
    rose-pine-btop-plain = pkgs.runCommandLocal "plain-rose-pine" { } ''
      cat ${rose-pine-btop}/rose-pine.theme > $out
    '';
  in
  {
    home.packages = [ base ];

    programs.btop = {
      enable = true;
      package = pkgs.btop-rocm;
      settings.color_theme = "rose-pine";
      themes.rose-pine = rose-pine-btop-plain;
    };
  }
)
// {
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
