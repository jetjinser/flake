{
  lib,
  config,
  ...
}:

let
  enable = true;

  cfg = config.services.forgejo;
in
{
  services.forgejo = {
    inherit enable;
    settings = {
      settings.COOKIE_SECURE = true;
      server = {
        PROTOCOL = "http"; # serve via CF tunnel
        DOMAIN = "code.bhu.social";
        ROOT_URL = "https://code.bhu.social";
      };
      log.LEVEL = "Warn";
    };
    dump = {
      enable = true;
      type = "tar.bz2";
    };
    database.type = "sqlite3";
  };

  services.cloudflared' = lib.mkIf cfg.enable {
    ingress = {
      code = cfg.settings.server.HTTP_PORT;
    };
  };
}
