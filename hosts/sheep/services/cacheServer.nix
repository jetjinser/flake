{ orgUrl
, atticdName
, atticdPort
}:

{ flake
, config
, pkgs
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
        let
          host = "${atticdName}.${orgUrl}";
        in
        {
          listen = "[::]:${atticdPort}";

          allowed-hosts = [
            host
            "127.0.0.1:${atticdPort}"
            "localhost:${atticdPort}"
            "[::1]:${atticdPort}"
            "[::]:${atticdPort}"
          ];
          api-endpoint = "https://${host}/";

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
