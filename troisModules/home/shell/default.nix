{
  pkgs,
  lib,
  ...
}:

let
  mkPlugin = pkg: { inherit (pkg) name src; };
  LS_COLORS = pkgs.fetchFromGitHub {
    owner = "trapd00r";
    repo = "LS_COLORS";
    rev = "81e2ebcdc2ed815d17db962055645ccf2125560c";
    hash = "sha256-ePs7UlgQqh3ptRXUNlY/BDa/1aH9q3dGa3h0or/e6Kk=";
  };
  rose-pine = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "fish";
    rev = "38aab5baabefea1bc7e560ba3fbdb53cb91a6186";
    hash = "sha256-bSGGksL/jBNqVV0cHZ8eJ03/8j3HfD9HXpDa8G/Cmi8=";
  };
in
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # source ${./tide.fish}
        fish_config theme choose "Rosé Pine"
        source ${LS_COLORS}/lscolors.csh
      '';
      preferAbbrs = true;
      shellAbbrs = import ./abbrs.nix;
      functions = import ./functions.nix;
      plugins = with pkgs.fishPlugins; [
        (mkPlugin colored-man-pages)
        (mkPlugin pisces)
        # (mkPlugin tide)
      ];
    };

    nix-index.enable = true;
    nix-index-database.comma.enable = true;
  };
  xdg.configFile."fish/themes" = {
    source = "${rose-pine}/themes";
    recursive = true;
  };
}
