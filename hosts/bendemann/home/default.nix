{ lib
, ...
}:

{
  home.stateVersion = lib.mkForce "22.05";

  imports = [
    ./terminal.nix
    ./firefox.nix
    ./chat.nix
    ./wm.nix
    ./audio.nix
    ./viewer.nix
  ];
}
