{ pkgs
, config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  imports = [
    ../../../modules/servicy/betula.nix
  ];

  servicy.betula = {
    enable = true;
  };

  services.akkoma = {
    enable = false;
    config =
      let
        ec = pkgs.formats.elixirConf { };
      in
      with ec.lib; {
        ":logger" = {
          ":ex_syslogger" = {
            level = ":info";
          };
        };
        ":pleroma" = {
          "Pleroma.Web.Endpoint" = {
            url = {
              host = "social.yeufossa.org";
              scheme = "https";
            };
            http = {
              port = 8889;
              ip = "127.0.0.1";
            };
          };
          "Pleroma.User" = {
            restricted_nicknames = [ ];
          };
          # FIXME: TLS :client: In state :hello received SERVER ALERT: Fatal - Handshake Failure
          "Pleroma.Emails.Mailer" = {
            enabled = true;
            adapter = mkRaw "Swoosh.Adapters.SMTP";
            relay = "smtp.qcloudmail.com";
            username = "noreply@yeufossa.org";
            password._secret = secrets.qcloudmailPWD.path;
            port = 465;
            ssl = true;
            tls = mkAtom ":always";
            auth = mkAtom ":always";
          };
          ":configurable_from_database" = true;
          ":instance" = {
            name = "YEUFOSSA Social";
            email = "admin@yeufossa.org";
            notify_email = "noreply@yeufossa.org";
            # TODO:
            description = "TBD";
            registrations_open = false;
            invites_enabled = true;
            federating = false;
            allow_relay = true;
            public = false;
            # TODO:
            autofollowed_nicknames = [ ];
            healthcheck = true;
            # TODO:
            local_bubble = [ ];
            languages = [ "zh" "en" ];
            # TODO:
            export_prometheus_metrics = false;
          };
          ":welcome" = {
            # TODO:
            direct_message = {
              enabled = true;
              sender_nickname = "YEUFOSSA";
              message = "欢迎";
            };
          };
        };
      };
  };
}
