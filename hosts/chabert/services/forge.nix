{
  lib,
  config,
  ...
}:

let
  enable = true;
  domain = "code.bhu.social";

  cfg = config.services.forgejo;
in
{
  services.forgejo = {
    inherit enable;
    settings = {
      settings.COOKIE_SECURE = true;
      server = {
        PROTOCOL = "http"; # serve via CF tunnel
        DOMAIN = domain;
        ROOT_URL = "https://${domain}";
      };
      log.LEVEL = "Warn";
      service.DISABLE_REGISTRATION = true;
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
