{ lib
, modulesPath
, inputs
, ...
}:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
      inputs.impermanence.nixosModules.impermanence
    ];

  boot = {
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

    tmp.useTmpfs = true;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var"
    ];
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05"; # Did you read the comment?
}
