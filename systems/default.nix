args:

let
  ipt = path: import path args;
in

builtins.foldl' (x: y: x // y) { }
  (builtins.map ipt
    [
      ./darwin
      ./nixos
      ./colmena
    ])
