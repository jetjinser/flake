{
  config,
  lib,
  ...
}:

let
  cfg = config.services.wakapi;

  inherit (config.sops) secrets;
  inherit (config.users) users;
in
{
  services = {
    wakapi = {
      enable = true;
      # TODO: smtp
      environmentFiles = [ secrets.passwordSalt.path ];
      database.dialect = "postgres";
      settings = {
        app.support_contact = "aimer@purejs.icu";
        server = {
          port = 9001;
          public_url = "https://waka.bhu.social";
        };
        security = {
          insecure_cookies = false;
        };
      };
    };
    postgresql = {
      enable = true;
      ensureDatabases = [ cfg.database.name ];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  sops.secrets = lib.mkIf cfg.enable {
    passwordSalt.owner = users.wakapi.name;
  };

  services.cloudflared'.ingress = lib.mkIf cfg.enable {
    waka = cfg.settings.server.port;
  };
}
