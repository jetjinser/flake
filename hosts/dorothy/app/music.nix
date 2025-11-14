{
  flake,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
in
mkHM (_: {
  # home.packages = with pkgs; [ ];
})
// {
}
