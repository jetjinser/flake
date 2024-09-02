{ lib
, config
, ...
}:


let
  inherit (config) malib symbols;
in
{
  perSystem = { pkgs, config, ... }:
    let
      inherit (malib pkgs) mkCmdGroup;
      NixCallCmdGroup = mkCmdGroup "NixCall" [
        {
          name = "up";
          help = "Update nix flake";
          command = "nix flake update";
        }
        {
          name = "upp";
          help = "Update specific input";
          command = "nix flake lock --update-input $1";
        }
        {
          name = "repl";
          help = "Start nix repl with nixpkgs";
          command = "nix repl -f flake:nixpkgs";
        }
        {
          name = "gc";
          help = "Garbage collect all unused nix store entries";
          command = ''
            if [ "$EUID" -ne 0 ]
              then echo -e "\e[33mwarnning: run as root\e[0m" >&2
              sudo -H nix store gc --debug
              sudo -H nix-collect-garbage --delete-old
            fi

            nix store gc --debug
            nix-collect-garbage --delete-old
          '';
        }
        {
          # name = "nfmt";
          # help = "Format the current flake";
          # command = "nix fmt";
          package = config.treefmt.build.wrapper;
        }
        {
          name = "rebuild";
          help = "Rebuild system to contain a specified system configuration output";
          command = builtins.readFile ../../scripts/rebuild.zuo;
        }
      ];
      MiscCmdGroup = mkCmdGroup "Misc" [
        {
          name = "dr";
          help = "Direnv reload";
          command = "direnv reload";
        }
        {
          name = "gitgc";
          help = "Garbage collect git store";
          command = ''
            git reflog expire --expire-unreachable=now --all
            git gc --prune=now
          '';
        }
        {
          name = "lspath";
          help = "list $PATH line by line";
          command = "printenv PATH | tr ':' '\n'";
        }
        {
          name = "batype";
          help = "Bat content of command";
          command = ''
            bat $(type -P $1) "''${@:2}"
          '';
        }
        {
          name = "machines";
          help = "List all of machines";
          command =
            let
              inherit (symbols) machines people;

              mapper = name: opt: ''
                echo -n "- ${name}  "

                if (ssh -q -p ${toString opt.port} "${people.myself}@${opt.host}" "exit")
                then
                  echo -e "\t\e[0;32m✅ running\e[0m"
                else
                  echo -e "\t\e[0;31m❌ down\e[0m"
                fi
              '';
            in
            lib.concatLines (lib.mapAttrsToList mapper machines);
        }
      ];
    in
    {
      devshells.default = {
        commands = NixCallCmdGroup ++ MiscCmdGroup;
        packages = with pkgs; [ sops ];
      };
    };
}
