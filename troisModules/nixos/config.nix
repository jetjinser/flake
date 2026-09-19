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

  # NOTE: programs.command-not-found and security.sudo-rs live in
  # nixosModules.common (nix-darwin has neither option).

  nixpkgs.overlays = [
    flake.inputs.deploy-rs.overlays.default
    (_self: super: {
      deploy-rs = {
        inherit (pkgs) deploy-rs;
        inherit (super.deploy-rs) lib;
      };
    })
    flake.self.overlays.default
    # niri only offers tiled multi-plane DMA-BUF formats for PipeWire
    # screencasts, so clients that need SHM (WeMeet, Discord) fail with
    # "no more input formats". This is upstream niri PR #1791.
    (_self: super: {
      niri = super.niri.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ../../patches/niri-shm-sharing.patch ];
      });
    })
  ];
}
