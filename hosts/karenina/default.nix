{ flake
, ...
}:

{
  imports = [
    flake.self.nixosModules.karenina

    ./configuration.nix
    # ./disko-config.nix
    ./hardware.nix
    ./network.nix

    ../share/cloud
  ];

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    # TODO: needed by share
    overlays = [
      flake.inputs.neovim-nightly-overlay.overlay
    ];
  };

  # At 22:45.
  services.cron = {
    enable = false;
    systemCronJobs = [
      "45 22 * * * root poweroff"
    ];
  };
}
