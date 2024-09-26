let
  config_path = ../../config;
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

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = builtins.fromTOML (builtins.readFile (config_path + /starship.toml));
    };

    nix-index.enable = true;
  };
}
