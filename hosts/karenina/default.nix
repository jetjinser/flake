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

    ../share/cloud
  ];

  nixpkgs = {
    hostPlatform = "aarch64-linux";
  };

  # At 22:45.
  services.cron = {
    enable = false;
    systemCronJobs = [
      "45 22 * * * root poweroff"
    ];
  };
}
