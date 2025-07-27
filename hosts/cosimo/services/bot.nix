{
  config,
  flake,
  lib,
  ...
}:

let
  cfg = config.services;

  inherit (config.sops) secrets;
in
{
  imports = [
    flake.inputs.quasique.nixosModules.default
    flake.config.modules.nixos.misc
  ];
  nixpkgs = {
    overlays = [ flake.inputs.quasique.overlays.default ];
    superConfig.allowUnfreeList = [ "qq" ];
  };

  sops.secrets = lib.mkIf cfg.quasique.enable {
    qqNumber.owner = cfg.quasique.user;
  };
  services.quasique = {
    enable = false;
    qqPath = secrets.qqNumber.path;
  };
}
