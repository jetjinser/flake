{
  flake,
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  gnomeCfg = config.services.desktopManager.gnome;
  niriCfg = config.programs.niri;
in
{
  services.greetd = {
    enable = true;
    settings = lib.mkMerge [
      (lib.mkIf niriCfg.enable {
        default_session = {
          command = ''
            ${lib.getExe pkgs.tuigreet} --cmd niri-session --greeting 'welcome back'
          '';
          user = myself;
        };
      })
      (lib.mkIf gnomeCfg.enable {
        gnome_session = {
          command = ''
            ${lib.getExe pkgs.tuigreet} --cmd gnome-session --greeting 'welcome back'
          '';
          user = myself;
        };
      })
    ];
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
