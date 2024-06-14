{ pkgs
, lib
, config
, ...
}:

{
  env = [ ];

  commands =
    let category = "NixCall";
    in [
      {
        inherit category;
        name = "up";
        help = "Update nix flake";
        command = "nix flake update";
      }
      {
        inherit category;
        name = "upp";
        help = "Update specific input";
        command = "nix flake lock --update-input $1";
      }
      {
        inherit category;
        name = "repl";
        help = "Start nix repl with nixpkgs";
        command = "nix repl -f flake:nixpkgs";
      }
      {
        inherit category;
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
        inherit category;
        name = "fmt";
        help = "Format the current flake";
        command = "nix fmt";
      }
    ] ++ (
      let
        category = "Misc";
      in
      [
        {
          inherit category;
          name = "re";
          help = "Direnv reload";
          command = "direnv reload";
        }
        {
          inherit category;
          name = "gitgc";
          help = "Garbage collect git store";
          command = ''
            git reflog expire --expire-unreachable=now --all
            git gc --prune=now
          '';
        }
        {
          inherit category;
          name = "lspath";
          help = "list $PATH line by line";
          command = "printenv PATH | tr ':' '\n'";
        }
        {
          inherit category;
          name = "batype";
          help = "Bat content of command";
          command = "bat $(type -P $1)";
        }
        {
          inherit category;
          name = "machines";
          help = "List all of machines";
          command =
            let
              inherit (config.symbols) machines people;

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
      ]
    )
  ;

  packages = with pkgs; [
    sops

    # attic-client
  ];
}
