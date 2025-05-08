{
  flake,
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (flake.config.lib) mkHM;
  inherit (flake.config.symbols.people) myself;

  cfg = config.home-manager.users.${myself}.programs.taskwarrior;
in
mkHM (
  { pkgs, ... }:
  {
    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      colorTheme = "dark-violets-256";
    };

    systemd.user.services = {
      TW-notify = {
        Unit = {
          Description = "send notifications when a task is about to be due";
          After = [ "mako.service" ];
          Requisite = [ "mako.service" ];
        };
        Service = {
          Type = "simple";
          ExecStart = pkgs.writers.writeGuile "tw-notify" { libraries = [ pkgs.guile-json ]; } (
            builtins.readFile ../../../scripts/tw.notify.scm
          );
        };
      };
    };
    systemd.user.timers = {
      TW-notify = {
        Unit.Description = "timer of TW-notify.service";
        Timer.OnCalendar = "*:0/07:0";
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  }
)
// {
  preservation.preserveAt."/persist" = lib.mkIf cfg.enable {
    users.${myself}.directories = [ cfg.dataLocation ];
  };
}
