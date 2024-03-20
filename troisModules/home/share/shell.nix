{ lib
, ...
}:

let
  config_path = ../../../config;
in
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile (config_path + /fish/config.fish);

      shellAbbrs = {
        g = "git";
        cdtmp = "cd (mktemp -d /tmp/jinser-XXXXXX)";
        decolorize = ''
          sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"
        '';
        nf = "nix flake";
        eproxy = "set -e {HTTP, HTTPS, ALL, FTP, RSYNC}_PROXY";
      };

      functions =
        let
          fnExt = ".fish";
          fn = name: builtins.readFile (config_path + /fish/functions/${name}.fish);
          allFns = with lib;
            mapAttrsToList
              (n: _: removeSuffix fnExt n)
              (filterAttrs
                (n: v: v == "regular" || hasSuffix fnExt n)
                (builtins.readDir (config_path + /fish/functions)));
        in
        lib.genAttrs allFns fn;
    };

    starship.enable = true;

    nix-index.enable = true;
  };
}
