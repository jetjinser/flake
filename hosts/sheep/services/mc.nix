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
  imports = [
    nix-minecraft.nixosModules.minecraft-servers
    flake.config.modules.nixos.misc
  ];

  config = lib.mkIf enable {
    nixpkgs.overlays = [ nix-minecraft.overlay ];
    nixpkgs.superConfig.allowUnfreeList = [ "forge-loader" ];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      dataDir = "/var/lib/minecraft";

      servers.creative-call =
        let
          modpack = pkgs.fetchPackwizModpack {
            url = "https://github.com/alt-jinser/creative-call/raw/v0.1.9/pack.toml";
            packHash = "sha256-6DQvnJaU18UsN8FfUXpg6Q1cdZILkcBf85XD6pydTFo=";
          };
        in
        {
          enable = true;
          autoStart = true;
          package = pkgs.forgeServers.forge-1_20_1;
          symlinks.mods = "${modpack}/mods";
          openFirewall = true;
          jvmOpts = import ./lib/jvmOpts.nix.data {
            minMemory = "15G";
            maxMemory = "15G";
          };
          serverProperties = {
            motd = "Dedicated for p1";
            online-mode = false;
            server-port = 27968;
            gamemode = "survival";
            difficulty = "hard";
            allow-flight = true;
          };
          operators.jetjinser = {
            uuid = "286e3291-3f44-392a-a1d1-e57ad515e071";
            level = 4;
            bypassesPlayerLimit = true;
          };
        };

      servers.p1 = {
        # disable vanilla server
        enable = false;
        autoStart = true;
        package = pkgs.papermcServers.papermc-1_21_10;
        openFirewall = true;
        jvmOpts = import ./lib/jvmOpts.nix.data {
          minMemory = "12G";
          maxMemory = "12G";
        };
        serverProperties = {
          motd = "Dedicated for p1";
          online-mode = false;
          server-port = 27968;
          gamemode = "survival";
          difficulty = "hard";
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
          "plugins/custom-join-messages.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/PJMIw5vh/versions/nOo9275N/custom-join-messages-17.9.1.jar";
            sha256 = "1ajhxapsn6h3rsj53ss242j614wpds5h47i1jqwfs1k0gmybm0av";
            name = "custom-join-messages.jar";
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

          "plugins/TPA.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/t0Xh802L/versions/1r1KbE2G/TPA-3.2.7.jar";
            sha256 = "1vfkmnwd0zshppz5d82k0yb9p1ajivzis9ad950kvh7l7gafv5yl";
            name = "TPA.jar";
          };
          "plugins/waypoints.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/1c2olKOU/versions/KVzhrgvx/waypoints-4.5.12.jar";
            sha256 = "1f7gwkgikd0ylkmmacbfcgd0w3w59mhl3jrycrnmp89dh5dv0vn8";
            name = "waypoints.jar";
          };

          "plugins/fast-leaf-decay.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/PcKMtamx/versions/vTcBP3lx/fast-leaf-decay-2.0.0.jar";
            sha256 = "17cnplghhn6widg0smsqbjkjnhnd20vphwn5i1ldw4fci3if4yya";
            name = "fast-leaf-decay.jar";
          };

          "plugins/pv-addon-discs.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/WXJRlyZ9/versions/C0AL9yNu/pv-addon-discs-1.1.8.jar";
            sha256 = "16q08lnsykgiba00q9p1b0bxy4j8jfw2m9amzaqi66sn6vc35kxi";
            name = "pv-addon-discs.jar";
          };
          "plugins/pv-addon-lavaplayer-lib.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/Kx9d4acU/versions/4iwym9sq/pv-addon-lavaplayer-lib-1.1.10.jar";
            sha256 = "0ys84x96pmhvpwd320v1a34h7w653y3gnlqvfbqd9xgh7wfn7bk1";
            name = "pv-addon-lavaplayer-lib.jar";
          };
          "plugins/PlasmoVoice.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/1bZhdhsH/versions/j9WvAurZ/PlasmoVoice-Paper-2.1.6.jar";
            sha256 = "1i55i7hr637l9f94p7znlyrs6k6xh0331z7ys4z8cc665wf41fl8";
            name = "PlasmoVoice.jar";
          };
          "plugins/packetevents.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/HYKaKraK/versions/7igcjlxa/packetevents-spigot-2.10.1.jar";
            sha256 = "1pszv1bbjnsxdsgnady5kar7q8n3l7r0bbgpfjkaqifpd6njfmx6";
            name = "packetevents.jar";
          };

          "plugins/Emotecraft.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/pZ2wrerK/versions/LIpzyVhC/emotecraft-paper-for-MC1.21.9-3.1.0-b.build.129.jar";
            sha256 = "0k6szshlxl4hnhw3gr50blddzzy3sszgbck625m1hhi8zspcxpbv";
            name = "Emotecraft.jar";
          };

          "plugins/Chunky.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/fALzjamp/versions/P3y2MXnd/Chunky-Bukkit-1.4.40.jar";
            sha256 = "08cpq11i83rc949b33dj4dvf2dmqpr6y676ybbhi447ph3y7fm1a";
            name = "Chunky.jar";
          };

          "plugins/FreedomChat.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/MubyTbnA/versions/I5w2b5Lf/FreedomChat-Paper-1.7.6.jar";
            sha256 = "1gkwybwqp3h2xlnz05jiz4fw44w55r7cyf9rj6pk9qrfmymn2gmk";
            name = "FreedomChat.jar";
          };

          "plugins/BlueMap.jar" = builtins.fetchurl {
            url = "https://cdn.modrinth.com/data/swbUV1cr/versions/wpE4tHiK/bluemap-5.13-paper.jar";
            sha256 = "19sjxh2czaqbdw4n0s35k9m7xa8306g4d8c5py2dyr2r9wzhnhra";
            name = "BlueMap.jar";
          };
        };
        # intended to re-save
        files = {
          "plugins/Backuper/config.yml" =
            let
              autoBackupPeriodInHours = 8;
            in
            {
              value = {
                storage.local = {
                  type = "local";
                  enabled = true;
                  autoBackup = true;
                  autoBackupPeriod = autoBackupPeriodInHours * 60; # in minutes
                  backupsFolder = "./plugins/Backuper/Backups";
                  maxBackupsNumber = (24 / autoBackupPeriodInHours) * 7; # keep backups for 1 week
                  maxBackupsWeight = 0;
                  zipArchive = true;
                  zipCompressionLevel = 7;
                };
                server.checkUpdates = false;
              };
            };
        };
      };
    };
    networking.firewall.allowedUDPPorts = [ 38814 ];

    # services.cloudflared' = {
    #   # Minecraft BlueMap plugin listen port
    #   ingress.map = 8100;
    # };
  };
}
