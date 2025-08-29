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
      enableDefaultConfig = false;
      matchBlocks = hosts // {
        "github.com" = {
          proxyCommand = "nc -x localhost:7890 -Xconnect %h %p";
        };
        "*" = {
          serverAliveInterval = 128;

          addKeysToAgent = "no";
          addressFamily = null;
          certificateFile = [ ];
          checkHostIP = true;
          compression = false;
          controlMaster = "no";
          controlPath = "~/.ssh/master-%r@%n:%p";
          controlPersist = "no";
          dynamicForwards = [ ];
          extraOptions = { };
          forwardAgent = false;
          forwardX11 = false;
          forwardX11Trusted = false;
          hashKnownHosts = false;
          host = null;
          hostname = null;
          identitiesOnly = false;
          identityAgent = [ ];
          identityFile = [ ];
          localForwards = [ ];
          match = null;
          port = null;
          proxyCommand = null;
          proxyJump = null;
          remoteForwards = [ ];
          sendEnv = [ ];
          serverAliveCountMax = 3;
          setEnv = { };
          user = null;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };
      };
    };
}
