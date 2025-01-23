{ lib
, config
, ...
}:

{
  perSystem = { pkgs, ... }:
    let
      inherit (pkgs.stdenv) isDarwin;
      inherit (config.lib) mkCmdGroup;
      NixDarwinCmdGroup = mkCmdGroup "NixDarwin" [
        {
          name = "sproxy";
          help = "Set proxy for nix-daemon via launchctl";
          command =
            ''
              cmd="python3 scripts/darwin_set_proxy.py"

              if [ "$EUID" -ne 0 ]; then
                echo -e "\e[33mwarning: run as root\e[0m" >&2
                command sudo $cmd
                exit 0
              fi

              $cmd
            '';
        }
      ];
    in
    {
      devshells.default = lib.optionalAttrs isDarwin {
        commands = NixDarwinCmdGroup;
      };
    };
}
