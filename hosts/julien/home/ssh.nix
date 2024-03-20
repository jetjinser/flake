{ lib
, flake
, ...
}:

let
  inherit (flake.config.symbols) machines;
  inherit (flake.config.symbols.people) myself;
in
{
  # TODO: Decouple this list
  programs.ssh =
    let
      hosts = {
        cosimo = {
          hostname = machines.aliyun.host;
          user = "root";
        };
        mimo = {
          hostname = machines.aliyun.host;
          user = myself;
        };

        chabert = {
          hostname = machines.jdcloud.host;
          user = "root";
        };
        cher = {
          hostname = machines.jdcloud.host;
          user = myself;
        };

        sheep = {
          hostname = machines.miecloud.host;
          inherit (machines.miecloud) port;
          user = "root";
        };
        mie = {
          hostname = machines.miecloud.host;
          inherit (machines.miecloud) port;
          user = myself;
        };

        barnabas = {
          hostname = machines.nanopi-r2s.host;
          user = "root";
        };
        barney = {
          hostname = machines.nanopi-r2s.host;
          user = myself;
        };

        karenina = {
          hostname = machines.rpi4.host;
          user = "root";
        };
        anna = {
          hostname = machines.rpi4.host;
          user = myself;
        };
      };
    in
    {
      enable = true;
      matchBlocks = hosts // {
        "github.com" = lib.hm.dag.entryAfter (builtins.attrNames hosts) {
          proxyCommand = "nc -X connect -x 127.0.0.1:7890 %h %p";
          serverAliveInterval = 10;
        };
      };
    };
}
