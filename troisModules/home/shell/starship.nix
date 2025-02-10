{
  ...
}:

let
  config_path = ../../../config;
in
{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = builtins.fromTOML (builtins.readFile (config_path + /starship.toml));
  };
}
