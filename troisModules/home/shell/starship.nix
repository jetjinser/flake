_:

let
  config_path = ../../../config;
in
{
  programs.starship = {
    enable = false;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile (config_path + /starship.toml));
  };
}
