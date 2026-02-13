{
  lib,
  ...
}:

{
  # 虚拟机特定配置
  virtualisation.vmVariant = {
    virtualisation = {
      qemu.guestAgent.enable = true;
      memorySize = 1024;
      cores = 2;

      # 网络配置
      qemu.options = [
        "-netdev user,id=net0,hostfwd=tcp::2222-:22"
        "-device virtio-net-device,netdev=net0"
      ];
    };

    # 虚拟机特定的引导配置
    boot.loader.grub.enable = lib.mkForce true;
    boot.loader.grub.device = "/dev/vda";
    boot.loader.grub.efiSupport = false;

    # 内核参数
    boot.kernelParams = [
      "console=ttyS0,115200n8"
      "root=/dev/vda2"
      "rootwait"
      "rootfstype=ext4"
    ];

    # 文件系统
    fileSystems."/" = {
      device = "/dev/vda2";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
    };
  };
}
