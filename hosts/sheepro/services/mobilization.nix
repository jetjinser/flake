{
  config,
  pkgs,
  lib,
  ...
}:

let
  enable = true;

  inherit (config.sops) secrets;
  cfg = config.services.mobilizon;
in
{
  services.cloudflared' = lib.mkIf enable {
    ingress = {
      events = cfg.settings.":mobilizon"."Mobilizon.Web.Endpoint".http.port;
    };
  };

  services.mobilizon = {
    inherit enable;
    nginx.enable = false;
    settings.":mobilizon" =
      let
        inherit ((pkgs.formats.elixirConf { }).lib) mkAtom mkRaw;

        # https://github.com/NixOS/nixpkgs/blob/d781ca3607d6f9c1a41dd044c19abc10bb777d63/pkgs/pkgs-lib/formats.nix#L635-L640
        escapeElixir = lib.escape [
          "\\"
          "#"
          "\""
        ];
        string = value: "\"${escapeElixir value}\"";

        mkReadFile = filePath: mkRaw "File.read!(${string filePath})";
      in
      {
        ":instance" = {
          name = "BHU@sheepro";
          hostname = "events.bhu.social";
          email_from = "aimer@purejs.icu";
        };
        "Mobilizon.Web.Email.Mailer" = {
          adapter = mkAtom "Swoosh.Adapters.SMTP";
          relay = "smtp.gmail.com";
          port = 587;
          username = "cmdr.jv@gmail.com";
          password = mkReadFile secrets.smtppass.path;
          tls = mkAtom ":always";
          allowed_tls_versions = [
            (mkAtom ":tlsv1")
            (mkAtom ":\"tlsv1.1\"")
            (mkAtom ":\"tlsv1.2\"")
          ];
          retries = 1;
          no_mx_lookups = false;
          auth = mkAtom ":always";
        };
      };
  };

  sops.secrets = lib.mkIf cfg.enable {
    smtppass = {
      owner = "mobilizon";
      group = "mobilizon";
      mode = "0400";
    };
  };
}
