{
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024; # in megabytes
  }];

  # nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";

  time.timeZone = "Asia/Shanghai";
}
