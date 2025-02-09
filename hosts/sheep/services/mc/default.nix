{
  flake,
  pkgs,
  config,
  ...
}:

let
  cfg = config.services;
in
{
  imports = [
    flake.inputs.nix-minecraft.nixosModules.minecraft-servers
    flake.config.modules.nixos.misc
  ];
  nixpkgs = {
    overlays = [ flake.inputs.nix-minecraft.overlay ];
    superConfig.allowUnfreeList = [ "minecraft-servers" ];
  };

  services.minecraft-servers = {
    enable = false;
    eula = true;
    openFirewall = true;
    servers.p1 = import ./p1.nix pkgs;
  };

  preservation.preserveAt."/persist" = {
    directories = [
      {
        directory = cfg.minecraft-servers.dataDir;
        inherit (cfg.minecraft-servers) user group;
        mode = "0741";
      }
    ];
  };
}
