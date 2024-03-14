{ credentialsFile
, atticdName
, atticdPort
, orgUrl
}:

{ inputs
, config
, pkgs
, lib
, ...
}:

let
  inherit (config.sops) secrets;

  atticdUser = "atticd";
  garageUser = "garage";

  rpcPort = "9877";
  s3ApiPort = "9878";
  s3WebPort = "9879";
  k2vApiPort = "9880";
  adminPort = "9881";
in
{
  imports = [
    inputs.attic.nixosModules.atticd
  ];

  users = {
    users = {
      ${atticdUser} = {
        isSystemUser = true;
        group = atticdUser;
      };
      ${garageUser} = {
        isSystemUser = true;
        group = garageUser;
      };
    };

    groups = {
      ${atticdUser} = { };
      ${garageUser} = { };
    };
  };

  systemd.services.garage.serviceConfig.User = garageUser;
  systemd.services.garage.serviceConfig.Group = garageUser;

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

    postgresql = {
      enable = true;
      ensureDatabases = [ atticdUser ];
      ensureUsers = [
        {
          name = atticdUser;
          ensureDBOwnership = true;
        }
      ];
      authentication = lib.mkOverride 10 ''
        # type  database        DBuser         address       auth-method
        local   all             all                          peer
        host    ${atticdUser}   ${atticdUser}  localhost     trust
      '';
    };

    garage = {
      enable = true;
      package = pkgs.garage_0_9_3;
      settings = {
        rpc_bind_addr = "[::]:${rpcPort}";
        rpc_public_addr = "127.0.0.1:${rpcPort}";
        rpc_secret_file = secrets.GarageRpcSecret.path;

        s3_api = {
          s3_region = "garage";
          api_bind_addr = "[::]:${s3ApiPort}";
          root_domain = ".s3.garage.localhost";
        };

        s3_web = {
          bind_addr = "[::]:${s3WebPort}";
          root_domain = ".web.garage.localhost";
          index = "index.html";
        };

        k2v_api = {
          api_bind_addr = "[::]:${k2vApiPort}";
        };

        admin = {
          api_bind_addr = "[::]:${adminPort}";
          admin_token_file = secrets.GarageAdminToken.path;
          metrics_token_file = secrets.GarageMetricsToken.path;
        };
      };
    };
  };
}
