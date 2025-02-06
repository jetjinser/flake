pkgs: lib:

let
  modpack = pkgs.fetchPackwizModpack {
    url = "https://github.com/alt-jinser/atm9sky-packwiz/raw/1.1.2/pack.toml";
    packHash = "sha256-L5RiSktqtSQBDecVfGj1iDaXV+E90zrNEcf4jtsg+wk=";
    manifestHash = "1sf9fnb8ws34vf1p0v4vxw2yjpjxz7z93qbcb5cwrr6sl5pwzbgx";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";

  commonProperties = import ./properties.nix;
  mkMotd = world: "hello §l${world}§r new sky";

  jvmOpts = import ./jvmOpts.nix {
    minMemory = "2560M";
    maxMemory = "3600M";
  };
in
{
  enable = true;
  inherit jvmOpts;

  serverProperties = commonProperties // {
    motd = mkMotd "AllTheMods";
    online-mode = false;
    difficulty = "hard";
  };

  # BUG: not fabric, but forge
  package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
  symlinks = {
    "mods" = "${modpack}/mods";
  };
}
