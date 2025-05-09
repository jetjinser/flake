{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    ...
  }:

  {
    programs.fish.functions = {
      battery = {
        description = "Show battery info";
        body = # fish
          ''
            upower -i (upower -e | grep battery)
          '';
      };
    };
  }
)
// {
}
