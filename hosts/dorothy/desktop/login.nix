{ pkgs
, lib
, ...
}:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session.command = ''
        ${lib.getExe pkgs.greetd.tuigreet} --cmd niri-session --remember --greeting 'welcome back'
      '';
    };
  };

  services.xserver.desktopManager.runXdgAutostartIfNone = true;
}
