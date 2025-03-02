{
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs) fetchurl;
  # https://github.com/NixOS/nixpkgs/blob/5954d3359cc7178623da6c7fd23dc7f7504d7187/pkgs/servers/dict/dictd-db.nix#L15C1-L36C7
  makeDictdDB =
    src: _name: _subdir: _locale:
    pkgs.stdenv.mkDerivation {
      name = "dictd-db-${_name}";
      inherit src;
      locale = _locale;
      dbName = _name;
      dontBuild = true;
      unpackPhase = ''
        tar xf  ${src}
      '';
      installPhase = ''
        mkdir -p $out/share/dictd
        cp $(ls ./${_subdir}/*.{dict*,index} || true) $out/share/dictd
        echo "${_locale}" >$out/share/dictd/locale
      '';
      meta = {
        description = "dictd-db dictionary for dictd";
        platforms = lib.platforms.linux;
      };
    };
in
{
  services.dictd =
    let
      eng2zho = makeDictdDB (fetchurl {
        url = "https://download.freedict.org/dictionaries/eng-zho/2024.10.10/freedict-eng-zho-2024.10.10.dictd.tar.xz";
        sha256 = "sha256-fOJCb6IIVKT5Gg/kcfE/JOmKtn/478ZglEdKwM/REN8=";
      }) "eng-zho" "eng-zho" "zh";
    in
    {
      enable = true;
      DBs =
        [ eng2zho ]
        ++ (with pkgs.dictdDBs; [
          wiktionary
          wordnet
        ]);
    };
}
