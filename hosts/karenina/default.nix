{
  flake,
  pkgs,
  ...
}:

{
  imports = [
    flake.self.nixosModules.karenina

    ./configuration.nix
    # ./disko-config.nix
    ./hardware.nix
    ./network.nix
    ./sops.nix
    ./services

    ../share/cloud
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  # disable man page generation
  # https://wiki.nixos.org/wiki/Fish#Disable_man_page_generation
  documentation.man.generateCaches = false;

  # systemd.services.poweroff-scheduled = {
  #   description = "Scheduled poweroff";
  #   # This tells systemd to start poweroff.target when this service is triggered
  #   unitConfig.Wants = [ "poweroff.target" ];
  #   serviceConfig.Type = "oneshot";
  # };
  #
  # systemd.timers.poweroff-scheduled = {
  #   description = "Timer for scheduled poweroff";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = [
  #       "Sun,Mon..Thu 22:45"
  #       "Fri,Sat 23:45"
  #     ];
  #     Persistent = true;
  #   };
  # };

  system.fsPackages = [ pkgs.seaweedfs ];
}
