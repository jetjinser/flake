{
  pkgs,
  lib,
  ...
}:

let
  config_path = ../../../config;
in
{
  starship = {
    enable = true;
    package = pkgs.starship.overrideAttrs (old: rec {
      version = "moonbit-lang";
      src = pkgs.fetchFromGitHub {
        owner = "jetjinser";
        repo = "starship";
        rev = "refs/heads/${version}";
        hash = "sha256-aeRlnkgu2IOW8Xv+gaby4SQFttxeZdn3LxWs5uuyOpE=";
      };
      cargoDeps = old.cargoDeps.overrideAttrs (
        lib.const {
          name = "${old.pname}-vendor.tar.gz";
          inherit src;
          outputHash = "sha256-6M9LCyp0amZ/pJySeMe75sP/IaA6Tta6djVTmtcxQTc=";
        }
      );
    });
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile (config_path + /starship.toml));
  };

}
