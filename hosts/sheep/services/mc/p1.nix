pkgs:

let
  commonProperties = import ./properties.nix;
  mkMotd = world: "hello §l${world}§r new world";
  jvmOpts = import ./jvmOpts.nix {
    minMemory = "8G";
    maxMemory = "16G";
  };
in
{
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
    "server-icon.png" = pkgs.fetchurl {
      url = "https://www.purejs.icu/open-64x64.png";
      sha512 = "sha512-jaowGShZr8xbpYAQ4I8WA/uMo/WvTlU5dWsyOsgr6UOEfc6ehrUCVxNa9bFIDb8VP8oK19eToX9whE0DiS9LXQ==";
    };
  };
  files = { };
}
