{
  pkgs,
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
in
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        # source ${./tide.fish}
        source ${LS_COLORS}/lscolors.csh
        # https://github.com/fish-shell/fish-shell/issues/10935
        bind --user ctrl-c cancel-commandline
      '';
      preferAbbrs = true;
      shellAbbrs = import ./abbrs.nix;
      functions = import ./functions.nix;
      plugins = with pkgs.fishPlugins; [
        (mkPlugin colored-man-pages)
        # (mkPlugin tide)
      ];
    };

    nix-index.enable = true;
    nix-index-database.comma.enable = true;
  };
}
