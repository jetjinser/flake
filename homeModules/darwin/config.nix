{ pkgs, lib, ... }:
{
  xdg = {
    enable = true;

    configFile = {
      "wezterm/wezterm.lua" = {
        source = pkgs.substitute {
          src = ../../config/wezterm.lua;
          replacements = [
            "--replace"
            "@nixFish@"
            (lib.getExe pkgs.fish)
          ];
        };
      };
    };
  };
}
