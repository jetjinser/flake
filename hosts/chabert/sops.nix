{ flake
, config
, ...
}:

let
  inherit (config.users) users;
in
{
  imports = [
    flake.inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      tailscaleAuthKey = { };
      statiqueTunnelJson.owner = users.cloudflared.name;
    };
  };
}
