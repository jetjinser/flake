pkgs: inputs:

# abandon: no forge support

let
  inherit (pkgs) lib;
  # inherit (inputs.nix-minecraft.lib) collectFilesAt;

  commonProperties = import ./properties.nix;
  mkMotd = world: "hello §l${world}§r new world";
  jvmOpts = import ./jvmOpts.nix {
    minMemory = "8G";
    maxMemory = "16G";
  };

  modpack = pkgs.fetchPackwizModpack {
    url = "https://raw.githubusercontent.com/alt-jinser/sf5-packwiz/5.0.7/pack.toml";
    packHash = lib.fakeHash;
    manifestHash = "sha256:0dn7f7v2qj1y12mnm58k0dwqn46257xm7wjn28dl141v78sbkfi8";
  };
  mcVersion = modpack.manifest.versions.minecraft;
  fabricVersion = modpack.manifest.versions.fabric;
  serverVersion = lib.replaceStrings [ "." ] [ "_" ] "fabric-${mcVersion}";
in
{
  enable = true;
  inherit jvmOpts;
  package = pkgs.fabricServers.${serverVersion}.override { loaderVersion = fabricVersion; };
  serverProperties = commonProperties // {
    motd = mkMotd "paper";
    online-mode = false;
    difficulty = "normal";
  };

  symlinks = {
    "server-icon.png" = pkgs.fetchurl {
      url = "https://www.purejs.icu/open-64x64.png";
      sha512 = "sha512-jaowGShZr8xbpYAQ4I8WA/uMo/WvTlU5dWsyOsgr6UOEfc6ehrUCVxNa9bFIDb8VP8oK19eToX9whE0DiS9LXQ==";
    };
    "mods" = "${modpack}/mods";
  };
  # files = collectFilesAt modpack "config" // { };
}
