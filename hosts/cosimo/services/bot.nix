{
  config,
  flake,
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

  sops.secrets = {
    qqNumber.owner = cfg.quasique.user;
  };
  services.quasique = {
    enable = true;
    qqPath = secrets.qqNumber.path;
  };
}
