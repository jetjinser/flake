_:

{
  mkHM = user: mod: {
    home-manager.users.${user} = _: {
      imports = mod;
    };
  };

  mkCmdGroup = category: cmds: map (attr: attr // { inherit category; }) cmds;
}
