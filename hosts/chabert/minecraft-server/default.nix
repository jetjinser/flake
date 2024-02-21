{ inputs
, pkgs
, ...
}:

{
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
  ];
  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    dataDir = "/var/lib/minecraft-servers";

    servers =
      let
        commonProperties = {
          server-port = 56552;
          "query.port" = 56552;
          "rcon.port" = 57552;
          enable-query = true;
        };
        mkMotd = world: "hello &l${world}&r new world";
        jvmOpts = import ./jvmOpts.nix {
          minMemory = "2560M";
          maxMemory = "2900M";
        };
      in
      {
        paper = {
          enable = true;
          inherit jvmOpts;
          # latest major version
          package = pkgs.paperServers.paper;
          serverProperties = commonProperties // {
            motd = mkMotd "paper";
            online-mode = false;
            difficulty = "normal";
          };

          symlinks = {
            plugins = pkgs.linkFarmFromDrvs "plugins" (builtins.attrValues {
              SkinsRestorer = pkgs.fetchurl {
                url = "https://github.com/SkinsRestorer/SkinsRestorerX/releases/download/15.0.2/SkinsRestorer.jar";
                sha512 = "sha512-DYmrQTUBtNvS26Q45sBL15YcQjLVh+MiI2AaA1H3LnWAQL2usIvulUBtmuyS3H4cGsUoqvt4dBN0AISOepHyhw==";
              };
            });
          };
        };
      };
  };
}
