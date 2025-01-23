{ flake
, pkgs
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM
  (
    { pkgs
    , ...
    }:

    let
      flakeRoot = ../../.;
      base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));
    in
    {
      home.packages = with pkgs; [
        radicle-node
      ] ++ [
        base
      ];
    }
  )
  //
{
  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ ".radicle" ];
  };
}

