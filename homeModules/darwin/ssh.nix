{ lib, ... }:

{
  programs.ssh =
    let
      ali = "106.14.161.118";
      jd = "117.72.45.59";

      hosts = {
        cosimo = {
          hostname = ali;
          user = "root";
        };
        mimo = {
          hostname = ali;
          user = "jinser";
        };

        chabert = {
          hostname = jd;
          user = "root";
        };
        cher = {
          hostname = jd;
          user = "jinser";
        };
      };
    in
    {
      enable = true;
      matchBlocks = hosts // {
        "*" = lib.hm.dag.entryAfter (builtins.attrNames hosts) {
          proxyCommand = "nc -X connect -x 127.0.0.1:7890 %h %p";
          serverAliveInterval = 10;
        };
      };
    };
}
