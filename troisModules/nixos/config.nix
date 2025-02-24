{
  flake,
  pkgs,
  ...
}:

{
  # i18n.defaultLocale = "zh_CN.UTF-8";

  # from whonix
  environment.etc.machine-id.source = ../machine-id;

  programs.command-not-found.enable = false;

  nixpkgs.overlays = [
    flake.inputs.deploy-rs.overlays.default
    (self: super: {
      deploy-rs = {
        inherit (pkgs) deploy-rs;
        lib = super.deploy-rs.lib;
      };
    })
  ];
}
