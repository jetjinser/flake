{
  flake,
  pkgs,
  ...
}:

let
  pkgs' = import flake.inputs.kanata-nixpkgs { inherit (pkgs.stdenv.hostPlatform) system; };
in
{
  services = {
    kanata = {
      enable = true;
      package = pkgs'.kanata;
      keyboards = {
        internal = {
          devices = [
            "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          ];
          config = ''
            (defsrc
              grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
              caps a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft      up
              lctl lmet lalt           spc            ralt      rctl      left down rght)

            (deflayer qwerty
              grv  1    2    3    4    5    6    7    8    9    0    -    =    \
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    bspc
              @cap a    s    d    f    g    h    j    k    l    ;    '    ret
              lsft z    x    c    v    b    n    m    ,    .    /    rsft      up
              lctl lmet lalt           spc            ralt      rctl      left down rght)

            (defalias
              cap (tap-hold 100 100 esc lctl))
          '';
        };
      };
    };
  };
}
