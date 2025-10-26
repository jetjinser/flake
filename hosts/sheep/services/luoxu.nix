{
  flake,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [ flake.inputs.berberman.overlays.default ];

  services.luoxu = {
    enable = false;
    package = pkgs.luoxu;
    configFile = ./config.toml;
  };
}
