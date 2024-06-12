{ lib
, ...
}:

let
  unfree-stuffs = [
    "qq"
  ];
in
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) unfree-stuffs;
  };
}
