{ pkgs
, ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];

    loader = {
      timeout = 1;
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 15;
      };
    };
    initrd = {
      includeDefaultModules = false;
    };
    blacklistedKernelModules = [
      "hantro_vpu"
      "drm"
      "lima"
      "videodev"
    ];
    kernel.sysctl = {
      "vm.vfs_cache_pressure" = 10;
      "vm.dirty_ratio" = 50;
      "vm.swappiness" = 20;
    };
  };

  hardware.deviceTree = {
    name = "rockchip/rk3328-nanopi-r2s.dtb";
    # NanoPi R2S's DTS has not been actively updated, so just use the prebuilt one to avoid rebuilding
    package = pkgs.lib.mkForce (
      pkgs.runCommand "dtbs-nanopi-r2s" { } ''
        install -TDm644 ${./files/rk3328-nanopi-r2s.dtb} $out/rockchip/rk3328-nanopi-r2s.dtb
      ''
    );
    # filter = "*rk3328-nanopi-r2s.dtb";
    # overlays = [{
    #   name = "sysled";
    #   dtsFile = ./files/sysled.dts;
    # }];
  };

  hardware.firmware = [
    (pkgs.runCommand
      "linux-firmware-r8152"
      { }
      ''
        install -TDm644 ${./files/rtl8153a-4.fw} $out/lib/firmware/rtl_nic/rtl8153a-4.fw
        install -TDm644 ${./files/rtl8153b-2.fw} $out/lib/firmware/rtl_nic/rtl8153b-2.fw
      ''
    )
  ];

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "ext4";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "f2fs";
      options = [ "compress_algorithm=zstd:6" "compress_chksum" "atgc" "gc_merge" "lazytime" ];
    };
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services = {
    lvm.enable = false;
    timesyncd.extraConfig = ''
      PollIntervalMinSec=16
      PollIntervalMaxSec=180
      ConnectionRetrySec=3
    '';
    fake-hwclock.enable = true;
  };

  networking.timeServers = [
    "ntp.aliyun.com"
    "ntp1.aliyun.com"
    "ntp2.aliyun.com"
    "ntp3.aliyun.com"
    "ntp4.aliyun.com"
    "ntp5.aliyun.com"
    "ntp6.aliyun.com"
    "ntp7.aliyun.com"
  ];

  systemd = {
    services = {
      "systemd-networkd" = {
        serviceConfig = {
          # avoid infinity restarting,
          # we want to tty into the system as network is not functional
          Restart = "no";
        };
      };
      "wait-system-running" = {
        description = "Wait system running";
        serviceConfig = { Type = "simple"; };
        script = ''
          systemctl is-system-running --wait
        '';
      };
      "setup-net-leds" = {
        description = "Setup network LEDs";
        serviceConfig = { Type = "simple"; };
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        script = ''
          ${pkgs.kmod}/bin/modprobe ledtrig_netdev
          cd /sys/class/leds/nanopi-r2s:green:lan
          echo netdev > trigger
          echo 1 | tee link tx rx >/dev/null
          echo intern0 > device_name

          cd /sys/class/leds/nanopi-r2s:green:wan
          echo netdev > trigger
          echo 1 | tee link tx rx >/dev/null
          echo extern0 > device_name
        '';
      };
      "setup-sys-led" = {
        description = "Setup booted LED";
        requires = [ "wait-system-running.service" ];
        after = [ "wait-system-running.service" ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          echo default-on > /sys/class/leds/nanopi-r2s:red:sys/trigger
        '';
      };
    };
    network.wait-online.timeout = 20;
    additionalUpstreamSystemUnits = [
      "systemd-time-wait-sync.service"
    ];
  };

}
