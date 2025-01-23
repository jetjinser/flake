{ config
, ...
}:


let
  mkHMs' = user: mods: {
    home-manager.users.${user} = _: {
      imports = mods;
    };
  };
  mkHM' = user: mod: {
    home-manager.users.${user} = _: {
      imports = [ mod ];
    };
  };

  inherit (config.symbols.people) myself;
in
{
  inherit mkHMs' mkHM';
  mkHMs = mkHMs' myself;
  mkHM = mkHM' myself;

  mkCmdGroup = category: cmds: map (attr: attr // { inherit category; }) cmds;
}
