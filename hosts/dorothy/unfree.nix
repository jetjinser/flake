{ lib
, ...
}:

let
  unfree-stuffs = [
    "qq"
    "fcitx5-rose-pine" # hum
    # "wemeet"
  ];
in
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) unfree-stuffs;
  };
}
