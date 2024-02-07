{ pkgs, lib, ... }:

{
  home.packages = [ ];

  programs = {
    git =
      let
        difft = lib.getExe pkgs.difftastic;
        bat = lib.getExe pkgs.bat;
      in
      {
        enable = true;
        userName = "Jinser Kafka";
        userEmail = "aimer@purejs.icu";
        aliases = {
          co = "checkout";
          st = "status";
          ci = "commit";
          br = "branch";
          dft = "difftool";
          dlog = "!f() { GIT_EXTERNAL_DIFF=${difft} git log -p --ext-diff $@; }; f";
        };
        extraConfig = {
          diff.tool = "difftastic";
          difftool = {
            prompt = false;
            difftastic = {
              cmd = ''
                ${difft} "$LOCAL" "$REMOTE"
              '';
            };
          };

          core.pager = "${bat} --theme ansi";
          pager.difftool = true;
        };
      };
  };
}
