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
