{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.dorothy

    flake.inputs.sops-nix.nixosModules.sops

    # keep-sorted start
    # ./music.nix
    ./app.nix
    ./configuration.nix
    ./disko-config.nix
    ./font.nix
    ./ime.nix
    ./keyboard.nix
    ./networking.nix
    ./persist.nix
    ./proxy.nix
    ./sops.nix
    ./unfree.nix
    ./helper.nix
    # keep-sorted end

    ./guix.nix
    ./dev

    ./desktop
    ../share/cloud/user.nix
  ];

  services.dbus.implementation = "broker";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  services.blueman.enable = true;

  programs.ssh.startAgent = true;

  hardware.enableRedistributableFirmware = true;

  nix.channel.enable = false;
}
