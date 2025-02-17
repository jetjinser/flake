{
  config,
  lib,
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

  preservation.preserveAt."/persist" =
    let
      wakapiServiceCfg = config.systemd.services.wakapi.serviceConfig;
    in
    {
      directories = [
        (lib.mkIf (cfg.wakapi.enable && wakapiServiceCfg.DynamicUser) {
          directory = "/var/lib/private/";
          user = users.root.name;
          inherit (users.root) group;
          mode = "0700";
        })
        (lib.mkIf (cfg.wakapi.enable && !wakapiServiceCfg.DynamicUser) {
          directory = cfg.wakapi.stateDir;
          user = users.wakapi.name;
          inherit (users.wakapi) group;
        })
      ];
    };
}
