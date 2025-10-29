{
  pkgs,
  lib,
  ...
}:

{
  programs = {
    git =
      let
        difft = lib.getExe pkgs.difftastic;
      in
      {
        enable = true;
        lfs.enable = true;
        settings = {
          user.name = "Jinser Kafka";
          user.email = "aimer@purejs.icu";
          alias = {
            co = "checkout";
            st = "status";
            ci = "commit";
            cim = "commit -m";
            civ = "commit -v";
            br = "branch";
            dft = "difftool";
            dlog = "!f() { GIT_EXTERNAL_DIFF=${difft} git log -p --ext-diff $@; }; f";
            dshow = "!f() { git difftool $1^ $1; }; f";
          };

          # I'm very nostalgic
          init.defaultBranch = "master";

          diff.tool = "difftastic";
          difftool = {
            prompt = false;
            difftastic = {
              cmd = ''
                ${difft} "$LOCAL" "$REMOTE"
              '';
            };
          };

          gpg = {
            format = "ssh";
            ssh.allowedSignersFile = "~/.ssh/allowed_signers";
          };
          user.signingkey = "~/.ssh/id_ed25519.pub";
          commit.gpgsign = true;

          # core.pager = "${bat} --theme ansi";
          pager.difftool = true;
        };
      };
  };
}
