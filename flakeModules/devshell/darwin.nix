{ lib
, config
, ...
}:

{
  perSystem = { pkgs, ... }:
    let
      inherit (pkgs.stdenv) isDarwin;
      inherit (config.malib pkgs) mkCmdGroup;
      NixDarwinCmdGroup = mkCmdGroup "NixDarwin" [
        {
          name = "sproxy";
          help = "Set proxy for nix-daemon via launchctl";
          command = ''
            cmd="python3 scripts/devshell/darwin/darwin_set_proxy.py"

            if [ "$EUID" -ne 0 ]; then
              echo -e "\e[33mwarning: run as root\e[0m" >&2
              command sudo $cmd
              exit 0
            fi

            $cmd
          '';
        }
        {
          name = "build";
          help = "Build system configuration result";
          command = builtins.readFile (pkgs.substitute {
            src = ../../scripts/devshell/darwin/build.sh;
            replacements = [
              "--replace"
              "@NOM@"
              (lib.getExe pkgs.nix-output-monitor)
            ];
          });
        }
        {
          name = "swos";
          help = "Switch system to contain a specified system configuration output";
          command = builtins.readFile (pkgs.substitute {
            src = ../../scripts/devshell/darwin/switch.sh;
            replacements = [
              "--replace"
              "@JQ@"
              (lib.getExe pkgs.jq)
            ];
          });
        }

        {
          name = "jule";
          help = "Switch system to `julien`";
          command = ''
            sproxy
            swos -n julien $@
            sproxy
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
