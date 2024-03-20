{ config
, ...
}:

let
  home = config.home.homeDirectory;
  keyFile = "${home}/.config/sops/age/keys.txt";
in
{
  sops = {
    age.keyFile = keyFile;
    defaultSopsFile = ./secrets.mp.json;
    defaultSymlinkPath = "${home}/.local/state/secrets";
    secrets = {
      server = { };
      uuid = { };
      security = { };
    };
  };
}
