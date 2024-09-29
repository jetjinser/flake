{ lib
, pkgs
, config
, flake
, ...
}:

{
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    flake.inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  services.irqbalance.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  programs.ssh.enableAskPassword = false;

  # enable iio for wluma
  hardware.sensor.iio.enable = true;

  zramSwap.enable = true;

  # systemd built-in oom killer
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  ];
  systemd.extraConfig = ''
    DefaultOOMPolicy=continue
  '';

  networking.hostName = "dorothy";
  time.timeZone = "Asia/Shanghai";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      # enable sysrq keys
      "kernel.sysrq" = 1;

      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_rmem" = "8192 262144 1073741824";
      "net.ipv4.tcp_wmem" = "4096 16384 1073741824";
      "net.ipv4.tcp_adv_win_scale" = -2;
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ ];
    };
    kernelModules = [
      "kvm-amd"
      "v4l2loopback"
    ];
    extraModulePackages = [
      config.boot.kernelPackages.v4l2loopback.out
    ];
    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    loader.systemd-boot.enable = true;
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.ens5.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05";
}
