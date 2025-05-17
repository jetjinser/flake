{
  flake,
  lib,
  config,
  ...
}:

let
  enable = true;

  inherit (flake.inputs) mathb;
  cfg = config.services.mathb;
in
{
  imports = [ mathb.nixosModules.default ];
  nixpkgs.overlays = [ mathb.overlays.default ];

  services.mathb = { inherit enable; };
  services.cloudflared' = lib.mkIf cfg.enable {
    ingress = {
      math = cfg.port;
    };
  };
}
