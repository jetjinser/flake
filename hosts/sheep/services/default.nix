{
  flake,
  config,
  ...
}:

let
  # FIXME: Wrong inclusion of `mc/jvmOpts`, `mc/properties`, `mc/p1.nix`
  #        broken on nested directories
  inherit (flake.config.lib) importx;

  inherit (config.sops) secrets;
  inherit (config.users) users;

  purejs = "purejs.icu";
  csTunnelID = "chez-sheep";
in
{
  # Manual temporary
  imports = importx ./. { };

  sops.secrets = {
    csTunnelJson = { };
    originCert.owner = users.cloudflared-dns.name;
  };
  services.cloudflared' = {
    tunnelID = csTunnelID;
    domain = purejs;
    credentialsFile = secrets.csTunnelJson.path;
    certificateFile = secrets.originCert.path;
  };
}
