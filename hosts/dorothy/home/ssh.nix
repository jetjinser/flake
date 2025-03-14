{
  flake,
  ...
}:

let
  inherit (flake.config.symbols) machines;
  inherit (flake.config.symbols.people) myself;
in
{
  programs.ssh =
    let
      hosts = {
        cosimo = {
          hostname = machines.aliyun.host;
          inherit (machines.aliyun) port;
          user = "root";
        };
        mimo = {
          hostname = machines.aliyun.host;
          inherit (machines.aliyun) port;
          user = myself;
        };

        chabert = {
          hostname = machines.jdcloud.host;
          inherit (machines.jdcloud) port;
          user = "root";
        };
        cher = {
          hostname = machines.jdcloud.host;
          inherit (machines.jdcloud) port;
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
        sheepro = {
          hostname = machines.miecloudpro.host;
          inherit (machines.miecloudpro) port;
          user = "root";
        };
        miex = {
          hostname = machines.miecloudpro.host;
          inherit (machines.miecloudpro) port;
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
      serverAliveInterval = 128;
      matchBlocks = hosts // {
        "github.com" = {
          proxyCommand = "nc -x localhost:7890 -Xconnect %h %p";
        };
      };
    };
}
