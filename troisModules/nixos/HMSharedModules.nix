{
  flake,
  ...
}:

{
  home-manager.sharedModules = [
    flake.inputs.sops-nix.homeManagerModules.sops
  ];
  home-manager.backupFileExtension = "backup";
}
