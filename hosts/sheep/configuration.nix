{ lib
, modulesPath
, flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      flake.inputs.impermanence.nixosModules.impermanence
    ];

  boot = {
    kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_rmem" = "8192 262144 1073741824";
      "net.ipv4.tcp_wmem" = "4096 16384 1073741824";
      "net.ipv4.tcp_adv_win_scale" = -2;
    };

    initrd = {
      availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "sr_mod"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "console=ttyS0" ];
    extraModulePackages = [ ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var"
    ];
    users.${myself} = {
      directories = [
        "project"
      ];
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05"; # Did you read the comment?
}
