{ config
, lib
, ...
}:

{
  home.sessionVariables = {
    WAKATIME_HOME = "${config.xdg.configHome}/waka";
  };

  xdg.configFile = {
    "waka/wakatime.cfg".source = (lib.traceValFn (x: builtins.attrNames x) config.sops).templates."wakatime.cfg".path;
  };
}
