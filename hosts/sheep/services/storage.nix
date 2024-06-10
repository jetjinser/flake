{ lib
, pkgs
, config
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
  services = {
    postgresql = {
      enable = false;
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
      enable = false;
      package = pkgs.garage_0_9_4;
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

  systemd.services.garage.serviceConfig.User = garageUser;
  systemd.services.garage.serviceConfig.Group = garageUser;

  users = {
    users = {
      ${garageUser} = {
        isSystemUser = true;
        group = garageUser;
      };
    };
    groups = {
      ${garageUser} = { };
    };
  };
}
