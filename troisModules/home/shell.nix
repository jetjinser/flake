{ lib
, ...
}:

let
  config_path = ../../config;
in
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = builtins.readFile (config_path + /fish/config.fish);

      shellAbbrs = {
        g = "git";
        n = "nvim";
        cdtmp = "cd (mktemp -d /tmp/jinser-XXXXXX)";
        decolorize = "sed -r \"s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g\"";
        nf = "nix flake";
        eproxy = "set -e {HTTP, HTTPS, ALL, FTP, RSYNC}_PROXY";
        bh = "bat --plain --language=help";
        hl = "bat -pp -l";
        sc = "systemctl";
        jc = "journalctl";
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

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = builtins.fromTOML (builtins.readFile (config_path + /starship.toml));
    };

    nix-index.enable = true;
  };
}
