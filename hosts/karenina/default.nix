{
  flake,
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

  # At 22:45.
  services.cron = {
    enable = false;
    systemCronJobs = [
      "45 22 * * * root poweroff"
    ];
  };
}
