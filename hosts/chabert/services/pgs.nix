{ flake
, ...
}:

# TODO:
# [x] ~~reverse proxy ssh 2222~~ use 22
# [ ] cf tunnel dynamic subdomain ingress
#     !! cf tunnel cannot ssl sub-subdomain.
# [ ] rewrite pgs web market page

{
  imports = [
    flake.inputs.pico.nixosModules.pgs
  ];

  services = {
    postgresql = {
      ensureDatabases = [ "pico" ];
      ensureUsers = [
        {
          name = "pgs";
          # ensureDBOwnership = true;
        }
      ];
    };

    pgs = {
      enable = true;
      openFirewall = true;
      environment = {
        DATABASE_URL = "postgres:///pico?host=/run/postgresql";
        PGS_PROTOCOL = "https";
        PGS_EMAIL = "hello@yeufossa.org";
        PGS_DOMAIN = "statique.icu";
        PGS_SSH_PORT = "22";
        PGS_WEB_PORT = "8300";
        # PGS_PROM_PORT = "9222";
      };
    };
  };
}
