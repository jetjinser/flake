{ lib
, ...
}:

let
  unfree-stuffs = [
    "qq"
    # "wemeet"
  ];
in
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) unfree-stuffs;
  };
}
