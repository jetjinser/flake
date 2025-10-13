{
  flake,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [ flake.inputs.berberman.overlays.default ];

  services.luoxu = {
    enable = true;
    package = pkgs.luoxu;
    configFile = ./config.toml;
  };
}
