{ pkgs
, ...
}:

{
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

  boot = {
    loader = {
      timeout = 1;
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 15;
      };
    };
    # NOTE: set by sd-image-aarch64-new-kernel-no-zfs-installer.nix
    # kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    kernelParams = [
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xff130000"
      "mitigations=off"
    ];
    initrd.includeDefaultModules = false;
    blacklistedKernelModules = [ "hantro_vpu" "drm" "lima" "videodev" ];
    tmp = {
      tmpfsSize = "70%";
      useTmpfs = true;
    };
  };

  boot.kernel.sysctl = {
    "vm.vfs_cache_pressure" = 10;
    "vm.dirty_ratio" = 50;
    "vm.swappiness" = 20;
  };

  powerManagement.cpuFreqGovernor = "schedutil";

  services.lvm.enable = false;

  services.timesyncd.extraConfig = ''
    PollIntervalMinSec=16
    PollIntervalMaxSec=180
    ConnectionRetrySec=3
  '';
  systemd.additionalUpstreamSystemUnits = [
    "systemd-time-wait-sync.service"
  ];
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

  systemd.services."systemd-networkd" = {
    serviceConfig = {
      # avoid infinity restarting,
      # we want to tty into the system as network is not functional
      Restart = "no";
    };
  };
  systemd.network.wait-online.timeout = 20;

  systemd.services."wait-system-running" = {
    description = "Wait system running";
    serviceConfig = { Type = "simple"; };
    script = ''
      systemctl is-system-running --wait
    '';
  };

  systemd.services."setup-net-leds" = {
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
      echo tailscale0 > device_name

      cd /sys/class/leds/nanopi-r2s:green:wan
      echo netdev > trigger
      echo 1 | tee link tx rx >/dev/null
      echo br-lan > device_name
    '';
  };
  systemd.services."setup-sys-led" = {
    description = "Setup activity LED";
    requires = [ "wait-system-running.service" ];
    after = [ "wait-system-running.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      ${pkgs.kmod}/bin/modprobe ledtrig_activity
      echo activity > /sys/class/leds/nanopi-r2s:red:sys/trigger
    '';
  };
}

