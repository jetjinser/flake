{
  lib,
  pkgs,
  flake,
  ...
}:

{
  imports = [
    flake.inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    flake.inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  nix.channel.enable = false;

  services.gvfs.enable = true;
  services.dbus.implementation = "broker";

  programs.ssh.enableAskPassword = false;

  documentation.dev.enable = true;

  # enable iio for wluma
  hardware.sensor.iio.enable = true;
  hardware.enableRedistributableFirmware = true;

  zramSwap.enable = true;

  # systemd built-in oom killer
  systemd.tmpfiles.rules = [
    "w /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000"
  ];
  systemd.settings.Manager = {
    DefaultOOMPolicy = "continue";
  };

  time.timeZone = "Asia/Shanghai";

  boot = {
    kernelParams = [
      # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Acquire_swap_file_offset
      "resume_offset=29500672"
      # https://bbs.archlinux.org/viewtopic.php?id=302499
      "amdgpu.dcdebugmask=0x10"
    ];
    resumeDevice = "/dev/disk/by-partlabel/ROOT";

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
      systemd.enable = true;
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
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    loader.systemd-boot = {
      enable = true;
      edk2-uefi-shell.enable = true;
    };
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
