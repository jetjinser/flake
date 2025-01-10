{ lib
, ...
}:

let
  unfree-stuffs = [
    "qq"
    "fcitx5-rose-pine" # hum
    # "wemeet"

    "steam"
    "steam-unwrapped"
    "steam-original"
    "steam-run"
  ];
in
{
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) unfree-stuffs;
  };
}
