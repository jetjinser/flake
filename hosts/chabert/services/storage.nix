{ lib
, ...
}:

{
  services = {
    postgresql = {
      enable = true;
      authentication = lib.mkOverride 10 ''
        # type  database        DBuser         address       auth-method
        local   all             all                          peer
      '';
    };
  };
}
