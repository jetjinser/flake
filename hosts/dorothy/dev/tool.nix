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

    authed-gh = pkgs.gh.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postInstall =
        (old.postInstall or "")
        + ''
          wrapProgram "$out/bin/gh" \
            --run 'export GH_TOKEN="$(cat ${secrets.GH_TOKEN.path})"'
        '';
    });
  in
  {
    home.packages = [
      base
      authed-gh
    ];

    programs.btop = {
      enable = true;
      package = pkgs.btop-rocm;
      settings.color_theme = "rose-pine";
      themes.rose-pine = rose-pine-btop-plain;
    };
  }
)
// {
  sops.secrets = {
    GH_TOKEN.owner = users.${myself}.name;
  };

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
