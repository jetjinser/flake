{
  config,
  lib,
  flake,
  ...
}:

let
  cfg = config.services.qbittorrent;
  inherit (config.sops) secrets;

  enable = true;
in
{
  config = lib.mkIf enable {
    services.qbittorrent = {
      enable = true;
      openFirewall = false;
      webuiPort = 19001;
      serverConfig = {
        LegalNotice.Accepted = true;
        Preferences = {
          WebUI = {
            Username = "jinser";
            Password_PBKDF2 = "m9LrTmRxSw/Fy4VwFESzuA==:0hvj5LV/SHl+PdNEt6+nTT79/g1dYsha4Dga9m1OBo6fRY7GPHmyNnp0d/JWgjyiW74ATUJQvcN7sJYacu9c0g==";
          };
        };
      };
    };

    sops.secrets.quiSessionSecret = { };
    services.qui = {
      inherit (cfg) enable;
      openFirewall = true;
      secretFile = secrets.quiSessionSecret.path;
      settings = {
        host = "anna.2jk.pw";
        port = 9001;
        logLevel = "WARN";
        metricsEnabled = false;
        checkForUpdates = false;
      };
    };

    services.peer-ban-helper = {
      inherit (cfg) enable;
      address = "anna.2jk.pw";
      port = 9898;
    };

    services.prowlarr = {
      enable = true;
      settings.server = {
        urlbase = "/";
        port = 19003;
        bindaddress = "100.80.144.122";
      };
    };

    services.caddy = {
      virtualHosts = lib.mkIf cfg.enable (
        let
          quiSettings = config.services.qui.settings;
        in
        {
          # TODO: cf dns tls
          "q.2jk.pw".extraConfig = ''
            tls ${../../../assets/karenina.crt} ${secrets.karenina-key.path}
            reverse_proxy ${quiSettings.host}:${toString quiSettings.port} {
              header_down X-Real-IP {http.request.remote}
              header_down X-Forwarded-For {http.request.remote}
            }
          '';
        }
      );
    };
  };
}
