{
  pkgs,
  lib,
  ...
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

  systemd.services.turnoffKbdBacklight = {
    description = "Turns off keyboard backlight when system on.";
    wantedBy = [ "multi-user.target" ];

    script =
      let
        brightnessctlBin = lib.getExe' pkgs.brightnessctl "brightnessctl";
      in
      "${brightnessctlBin} -d 'platform::kbd_backlight' set 0";

    serviceConfig.Type = "oneshot";
  };
}
