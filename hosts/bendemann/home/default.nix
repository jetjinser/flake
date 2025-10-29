{
  lib,
  ...
}:

{
  home.stateVersion = lib.mkForce "22.05";

  imports = [
    ./firefox.nix
    ./audio.nix
    ./viewer.nix
  ];
}
