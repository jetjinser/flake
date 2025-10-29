{
  flake,
  pkgs,
  ...
}:

{
  # i18n.defaultLocale = "zh_CN.UTF-8";
  time.timeZone = "Asia/Shanghai";

  # from whonix
  environment.etc.machine-id.source = ../machine-id;

  programs.command-not-found.enable = false;
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  nixpkgs.overlays = [
    flake.inputs.deploy-rs.overlays.default
    (_self: super: {
      deploy-rs = {
        inherit (pkgs) deploy-rs;
        inherit (super.deploy-rs) lib;
      };
    })
  ];
}
