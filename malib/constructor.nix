_:

{
  mkHM = user: mod: {
    home-manager.users.${user} = _: {
      imports = mod;
    };
  };
}
