{ lib, ... }:

{
  programs.ssh =
    let
      hosts = {
        mimo = {
          hostname = "106.14.161.118";
          user = "jinser";
        };
        cosimo = {
          hostname = "106.14.161.118";
          user = "root";
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
