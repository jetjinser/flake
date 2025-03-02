{
  cht = {
    description = "Check the cheat sheet for command";
    body = # fish
      ''
        curl -s "https://cht.sh/$argv"
        printf '\n'
      '';
  };
  del = {
    description = "Move file to trash";
    argumentNames = "target";
    body = # fish
      ''
        set -l trash_path '/tmp/trash'
        if not test -d $trash_path
          mkdir $trash_path
        end
        mv $target $trash_path
      '';
  };
  dict = {
    description = "Query words via dict protocol";
    argumentNames = [
      "word"
      "dicts"
    ];
    body = # fish
      ''
        set -q dicts[1]
        or set dicts "xdict,stardic"
        for dict in (string split ',' $dicts)
          curl -s "dict://dict.catflap.org/d:$word:$dict"| awk '
            /^220/ { server = $2 }

            /^151/ {
              flag = 1;
              $1 = "";
              printf "\033[1m%s\033[m\n", $2;
              $2 = "\b";
              dict = $0;
              next;
            }
            /^[.]/ {
              flag = 0;
              print "*\033[3m" dict "\033[m";
            }
            flag

            /^552/ {
              $1="\b"; printf "\033[35m%s %s\033[m\n", $2, $3
            }

            END { print "* \033[3m" server "\033[m" }
            '
          printf "\n"
        end
      '';
  };
  hst = {
    description = "Paste text to hastebin";
    body = # fish
      ''
        set -q HASTE_SERVER
        and set -f server "$HASTE_SERVER"
        or set -f server 'https://hastebin.purejs.icu'

        if isatty stdin
          set -f json (curl -s "$server/documents" --data-binary @$argv)
        else
          cat $argv 2>/dev/null | read -l -z content
          set -f json (curl -s "$server/documents" --data-binary $content)
        end

        echo $json | sed "s|{\"key\"\:\"\(.*\)\"}|$server/\1\n|"
      '';
  };
  hijack = {
    description = "Hijack file temporarily";
    body = # fish
      ''
        # https://lobste.rs/s/ahmi0i/quick_bits_realise_nix_symlinks#c_cajper

        set -l item
        for item in $argv
          if test ! -L $item
            continue
          end

          set -l bak (dirname $item)/.(basename $item).hijack.bak
          set -l tmp (string replace .bak .tmp $bak)

          cp --no-dereference --remove-destination $item $bak; or return $status

          rm -rf $tmp; or return $status
          cp -r (readlink --canonicalize $item) $tmp; or return $status
          chmod -R u+w $tmp; or return $status

          rm $item; or return $status

          mv $tmp $item; or return $status
        end

        $EDITOR -- $argv
        set -l ret $status

        for item in $argv
          set -l bak (dirname $item)/.(basename $item).hijack.bak

          if test ! -e $bak
            continue
          end

          mv $bak $item; or return $status
        end

        return $ret
      '';
  };
  nr = {
    description = "Shortcut for run package from nixpkgs";
    body = # fish
      ''
        nix run "nixpkgs#$argv[1]" $argv[2..]
      '';
  };
}
