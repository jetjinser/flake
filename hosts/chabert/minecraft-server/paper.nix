pkgs:

let
  commonProperties = import ./properties.nix;
  mkMotd = world: "hello §l${world}§r new world";
  jvmOpts = import ./jvmOpts.nix {
    minMemory = "2560M";
    maxMemory = "2900M";
  };
in
{
  enable = false;
  inherit jvmOpts;
  # latest major version
  package = pkgs.paperServers.paper;
  serverProperties = commonProperties // {
    motd = mkMotd "paper";
    online-mode = false;
    difficulty = "normal";
  };

  symlinks = {
    "plugins/SkinsRestorer.jar" = pkgs.fetchurl {
      url = "https://github.com/SkinsRestorer/SkinsRestorerX/releases/download/15.0.2/SkinsRestorer.jar";
      sha512 = "sha512-DYmrQTUBtNvS26Q45sBL15YcQjLVh+MiI2AaA1H3LnWAQL2usIvulUBtmuyS3H4cGsUoqvt4dBN0AISOepHyhw==";
    };
    "server-icon.png" = pkgs.fetchurl {
      url = "https://www.yeufossa.org/favicon-64x64.png";
      sha512 = "sha512-8ub86eIlUrjru7EYlmBmMdzwU72yUwHekftJnjBSOzTU6c5pT6uPrEjz4UM7h/fLpegDuD4NRQyuS6NoCxmdJw==";
    };
  };
  files = { };
}
