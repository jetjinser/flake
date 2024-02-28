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
        "virtio_blk"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];

    tmp.useTmpfs = true;
  };

  environment.persistence."/persist" = {
    directories = [
      "/var"
    ];
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05";
}
