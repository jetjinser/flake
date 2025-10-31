{
  services = {
    kanata = {
      enable = true;
      keyboards = {
        pasHHKB = {
          devices = [
            "/dev/input/by-id/usb-Telink_Wireless_Gaming_Keyboard-event-kbd"
            "/dev/input/by-id/usb-Telink_C65-event-kbd"
            "/dev/input/by-id/usb-Compx_2.4G_Wireless_Receiver-event-kbd"
          ];
          config = ''
            (defsrc
              grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    del
              caps a    s    d    f    g    h    j    k    l    ;    '    ret       pgup
              lsft z    x    c    v    b    n    m    ,    .    /    rsft      up   pgdn
              lctl lmet lalt           spc            ralt      rctl      left down rght)

            (deflayer qwerty
              grv  1    2    3    4    5    6    7    8    9    0    -    =    \
              tab  q    w    e    r    t    y    u    i    o    p    [    ]    bspc del
              @cap a    s    d    f    g    h    j    k    l    ;    '    ret       pgup
              lsft z    x    c    v    b    n    m    ,    .    /    rsft      up   pgdn
              lctl lmet lalt           spc            ralt      rctl      left down rght)

            (defalias
              cap (tap-hold 100 100 caps lctl))
          '';
        };
        perc40 = {
          devices = [
            "/dev/input/by-id/usb-0xCB_Static-event-kbd"
          ];
          config = ''
            (defsrc
              grv  q    w    e    r    t    y    u    i    o    p    bspc
              tab  a    s    d    f    g    h    j    k    l    ret
              lsft z    x    c    v    b    n    m    ,    .    rsft
              lctl lmet lalt           spc            ralt)

            (deflayer qwerty
              grv  q    w    e    r    t    y    u    i    o    p    bspc
              @tab  a    s    d    f    g    h    j    k    l    ret
              lsft z    x    c    v    b    n    m    ,    .    rsft
              lctl lmet lalt           spc            ralt)

            (defalias
              tab (tap-hold 120 120 tab lctl))
          '';
        };
      };
    };
  };
}
