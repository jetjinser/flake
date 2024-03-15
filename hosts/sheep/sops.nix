{ config
, inputs
, ...
}:

let
  inherit (config.users) users;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      SpOrgTunnelJson.owner = users.cloudflared.name;

      AtticCredentialsEnv.owner = users.atticd.name;

      GarageRpcSecret.owner = users.garage.name;
      GarageAdminToken.owner = users.garage.name;
      GarageMetricsToken.owner = users.garage.name;

      # TyphonPWD.owner = users.typhon.name;
    };
  };
}
