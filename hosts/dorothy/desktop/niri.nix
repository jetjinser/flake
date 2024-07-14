{ flake
, pkgs
, ...
}:

{
  imports = [
    flake.inputs.niri.nixosModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
}
