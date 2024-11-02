{ flake
, pkgs
, lib
, ...
}:

{
  imports = [
    flake.inputs.nix-minecraft.nixosModules.minecraft-servers
  ];
  nixpkgs.overlays = [ flake.inputs.nix-minecraft.overlay ];
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "minecraft-server"
      ];
  };

  services.minecraft-servers = {
    enable = false;
    eula = true;
    openFirewall = true;

    dataDir = "/var/lib/minecraft-servers";

    servers = {
      paper = import ./paper.nix pkgs;
      atm9sky = import ./atm9sky.nix pkgs lib;
    };
  };
}
