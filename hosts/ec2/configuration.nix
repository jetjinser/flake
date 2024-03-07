{ lib
, modulesPath
, ...
}:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  system.stateVersion = "24.05"; # Did you read the comment?
}
