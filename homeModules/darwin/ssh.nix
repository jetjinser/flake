{ pkgs
, lib
, ...
}:

let
  const = import ../../const.nix;
  inherit (const.machines) aliyun jdcloud miecloud;
in
{
  home.packages = [
    pkgs.mosh
  ];

  programs.ssh =
    let
      hosts = {
        cosimo = {
          hostname = aliyun.host;
          user = "root";
        };
        mimo = {
          hostname = aliyun.host;
          user = "jinser";
        };

        chabert = {
          hostname = jdcloud.host;
          user = "root";
        };
        cher = {
          hostname = jdcloud.host;
          user = "jinser";
        };

        sheep = {
          hostname = miecloud.host;
          inherit (miecloud) port;
          user = "root";
        };
        mie = {
          hostname = miecloud.host;
          inherit (miecloud) port;
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
