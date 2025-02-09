{
  pkgs,
  lib,
  ...
}:

let
  config_path = ../../../config;
in
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile (config_path + /fish/config.fish);

      preferAbbrs = true;
      shellAbbrs = import ./abbrs.nix;
      functions = import ./functions.nix;
    };

    nix-index.enable = true;
  };
}
