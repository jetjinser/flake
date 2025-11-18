{
  flake,
  config,
  lib,
  ...
}:

let
  cfg = config.services;

  # FIXME: Wrong inclusion of `mc/jvmOpts`, `mc/properties`, `mc/p1.nix`
  #        broken on nested directories
  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  purejs = "purejs.icu";
  csTunnelID = "chez-sheep";
in
{
  imports = (importx ./. { }) ++ [
    flake.config.modules.nixos.services
  ];

  sops.secrets = lib.mkIf cfg.cloudflared'.enable {
    csTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    tunnelID = csTunnelID;
    domain = purejs;
    credentialsFile = secrets.csTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };

  preservation.preserveAt."/persist" = {
    directories = [ "/var/lib" ];
  };
}
