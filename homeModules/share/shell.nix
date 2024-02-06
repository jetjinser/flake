let
  config_path = ../../config;
in
{
  programs = {
    fish = {
      enable = true;
      shellAliases = {
        g = "git";
        cdtmp = "cd (mktemp -d /tmp/jinser-XXXXXX)";
        decolorize = ''
          sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g"
        '';
      };
      functions =
        let
          fn = name: builtins.readFile (config_path + /fish/functions/${name}.fish);
        in
        {
          hst = fn "hst";
          del = fn "del";
          cht = fn "cht";
        };
      interactiveShellInit = builtins.readFile (config_path + /fish/config.fish);
    };

    starship.enable = true;
  };
}
