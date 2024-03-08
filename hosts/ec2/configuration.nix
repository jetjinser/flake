{ lib
, modulesPath
, inputs
, username
, ...
}:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      inputs.impermanence.nixosModules.impermanence
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
        "nvme"
      ];
      kernelModules = [ ];
    };

    kernelModules = [ ];
    kernelParams = [ ];
    extraModulePackages = [ ];
  };

  environment.persistence."/persist" = {
    directories = [
      "/var"
    ];
    users.${username} = {
      directories = [
        "project"
      ];
    };
  };

  services.qemuGuest.enable = true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05"; # Did you read the comment?
}
