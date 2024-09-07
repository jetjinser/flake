{ flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/${myself}/vie/projet/flake";
  };
}

