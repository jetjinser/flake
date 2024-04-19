{ config
, ...
}:

{
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024; # in megabytes
  }];

  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = config.system.nixos.release;

  time.timeZone = "Asia/Shanghai";

  programs = {
    command-not-found.enable = true;
  };
}
