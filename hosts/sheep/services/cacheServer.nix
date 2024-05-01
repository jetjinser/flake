{ atticdName
, atticdPort
}:

{ flake
, config
, lib
, ...
}:

let
  inherit (config.sops) secrets;

  credentialsFile = secrets.AtticCredentialsEnv.path;

  atticdUser = "atticd";

  s3ApiPort = "9878";
in
{
  imports = [
    flake.inputs.attic.nixosModules.atticd
  ];

  networking.firewall.allowedTCPPorts = [ (lib.toInt atticdPort) ];

  users = {
    users = {
      ${atticdUser} = {
        isSystemUser = true;
        group = atticdUser;
      };
    };
    groups = {
      ${atticdUser} = { };
    };
  };

  services = {
    atticd = {
      enable = true;

      user = atticdUser;
      group = atticdUser;

      inherit credentialsFile;

      settings =
        {
          listen = "[::]:${atticdPort}";

          # allowed-hosts = [
          #   "127.0.0.1:${atticdPort}"
          #   "localhost:${atticdPort}"
          #   "[::1]:${atticdPort}"
          #   "[::]:${atticdPort}"
          # ];
          # api-endpoint = "miecloud:${atticdPort}/";

          database = {
            url = "postgresql://${atticdUser}@localhost/${atticdUser}";
          };
          storage = {
            type = "s3";
            region = "garage";
            bucket = "cache-attic";
            endpoint = "http://localhost:${s3ApiPort}";
          };

          chunking = {
            nar-size-threshold = 64 * 1024; # 64 KiB
            min-size = 16 * 1024; # 16 KiB
            avg-size = 64 * 1024; # 64 KiB
            max-size = 256 * 1024; # 256 KiB
          };
        };
    };
  };
}
