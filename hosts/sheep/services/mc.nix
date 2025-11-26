{
  flake,
  lib,
  pkgs,
  ...
}:

let
  enable = true;

  inherit (flake.inputs) nix-minecraft;
in
{
  imports = [ nix-minecraft.nixosModules.minecraft-servers ];

  config = lib.mkIf enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      dataDir = "/var/lib/minecraft";

      servers.p1 = {
        enable = true;
        autoStart = true;
        package = pkgs.papermcServers.papermc-1_21_10;
        openFirewall = true;
        jvmOpts = import ./lib/jvmOpts.nix.data {
          minMemory = "4G";
          maxMemory = "4G";
        };
        serverProperties = {
          motd = "Dedicated for p1";
          online-mode = false;
          server-port = 27968;
          gamemode = "survival";
          difficulty = "normal";
          allow-flight = true;
        };
        operators.jetjinser = {
          uuid = "286e3291-3f44-392a-a1d1-e57ad515e071";
          level = 4;
          bypassesPlayerLimit = true;
        };
        symlinks = {
          "server-icon.png" = builtins.fetchurl {
            url = "https://www.purejs.icu/favicon-64x64.png";
            sha256 = "1i37hs7bffi2jd4ryhsycrl7ia3l14clqi7ywlhg3apmgidd5vsi";
          };
          # NOTE: 1.21.10 is newest version currently
          # "plugins/ViaVersion.jar" = builtins.fetchurl {
          #   url = "https://github.com/ViaVersion/ViaVersion/releases/download/5.5.1/ViaVersion-5.5.1.jar";
          #   sha256 = "041hyyvj7hcmmdfa4aa7bq9vhj2ihglp51r0nla1gb1yyr97a78p";
          #   name = "ViaVersion.jar";
          # };
          "plugins/SkinRestorer.jar" = builtins.fetchurl {
            url = "https://github.com/SkinsRestorer/SkinsRestorer/releases/download/15.9.0/SkinsRestorer.jar";
            sha256 = "1bfjk94dpmr7q4awaq4nzzyg4hv68pqhx2v32a11z6gqmfamj3ab";
            name = "SkinRestorer.jar";
          };
          "plugins/Backuper.jar" = builtins.fetchurl {
            url = "https://github.com/DVDishka/Backuper/releases/download/4.0.1a/Backuper-4.0.1a.jar";
            sha256 = "0qs8ilqj8g2w8r3l6bl5jp1iw1pnpqis64rxj84ynjnrk583bjqx";
            name = "Backuper.jar";
          };
          "plugins/Backuper/config.yml" = {
            value = {
              storage.local = {
                type = "local";
                enabled = true;
                autoBackup = true;
                autoBackupPeriod = 12 * 60; # 12 hours in minutes
                backupsFolder = "./plugins/Backuper/Backups";
                maxBackupsNumber = 14; # keep backups for 1 week
                maxBackupsWeight = 0;
                zipArchive = true;
                zipCompressionLevel = 7;
              };
            };
          };

          "plugins/LuckPerms.jar" = builtins.fetchurl {
            url = "https://download.luckperms.net/1609/bukkit/loader/LuckPerms-Bukkit-5.5.20.jar";
            sha256 = "0rhvmah76lqwcszaj83pdkagpfci8wck3wk4a9w2fxwy3g4prvgq";
            name = "LuckPerms.jar";
          };
          "plugins/PlaceholderAPI.jar" = builtins.fetchurl {
            url = "https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.11.7/PlaceholderAPI-2.11.7.jar";
            sha256 = "0pgbybdvdld3h80kcwl5xvqhlrm5lcz9iwz8rwc63axaidqym97m";
            name = "PlaceholderAPI.jar";
          };
          "plugins/CarbonChat.jar" = builtins.fetchurl {
            url = "https://github.com/Hexaoxide/Carbon/releases/download/v3.0.0-beta.36/carbonchat-paper-3.0.0-beta.36.jar";
            sha256 = "12xhfq76ksjrgk8skkyl8g0anbj9mzaj01lbqm09zx96m8av5lh6";
            name = "CarbonChat.jar";
          };

          "plugins/CalcMod.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/XoHTb2Ap/versions/kFCmDE3w/calcmod-1.4.3+paper.1.21.10.jar";
            sha256 = "0i82dyay87dnws9l04gqm1qqc80knhxaf4lrx3qd1jr56l36rh3y";
            name = "CalcMod.jar";
          };
          "plugins/ImageFrame.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/lJFOpcEj/versions/GH7zkF6d/ImageFrame-1.8.7.4.jar";
            sha256 = "1pql2ycnmxps8bscif45pl7xixpr5sir69a9w9jn8bwlffsj6jim";
            name = "ImageFrame.jar";
          };
          "plugins/TAB.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/gG7VFbG0/versions/njaHNTiW/TAB%20v5.3.2.jar";
            sha256 = "0lg2izr2h6225v9dakqh17kqm06kkyqnz8jclrqi55q9wwn1x019";
            name = "TAB.jar";
          };

          # "plugins/Emotecraft.jar" = builtins.fetchurl {
          #   url = "https://cdn.modrinth.com/data/pZ2wrerK/versions/LIpzyVhC/emotecraft-paper-for-MC1.21.9-3.1.0-b.build.129.jar";
          #   sha256 = "0k6szshlxl4hnhw3gr50blddzzy3sszgbck625m1hhi8zspcxpbv";
          #   name = "Emotecraft.jar";
          # };
          # NOTE: 1.21.9 latest
          # https://modrinth.com/mod/online-emotes
        };
      };
    };
  };
}
