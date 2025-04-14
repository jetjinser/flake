{
  flake,
  config,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;

  cfg = config.programs;
  hmc = config.home-manager.users.${myself}.programs;
in

{
  programs.nano.enable = !(cfg.neovim.enable || hmc.neovim.enable);
}
