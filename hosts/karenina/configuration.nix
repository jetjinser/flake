{
  pkgs,
  lib,
  ...
}:

{
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 4 * 1024; # in megabytes
    }
  ];

  boot = {
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_rmem" = "8192 262144 1073741824";
      "net.ipv4.tcp_wmem" = "4096 16384 1073741824";
      "net.ipv4.tcp_adv_win_scale" = -2;
    };

    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi4;
    kernelParams = [ "cma=64M" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  system.stateVersion = "24.05";
}
