{
  config,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
  inherit (config.users) users;
in
{
  services = {
    wakapi = {
      enable = true;
      # TODO: smtp
      passwordSaltFile = secrets.passwordSalt.path;
      database.dialect = "postgres";
      settings = {
        app.support_contact = "aimer@purejs.icu";
        server = {
          port = 9001;
          public_url = "https://waka.purejs.icu";
        };
        security = {
          insecure_cookies = false;
        };
      };
    };
    postgresql = {
      enable = true;
      ensureDatabases = [ cfg.wakapi.database.name ];
      ensureUsers = [
        {
          name = cfg.wakapi.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
  };

  sops.secrets = {
    passwordSalt.owner = users.wakapi.name;
  };

  services.cloudflared'.ingress = {
    waka = cfg.wakapi.settings.server.port;
  };

  # TODO: persist
}
