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
    # waylyrics: track upstream for the layer-shell feature
    # (https://github.com/waylyrics/waylyrics/issues/423),
    # nixpkgs is still on 0.3.21 which lacks it.
    (_self: super: {
      waylyrics = super.waylyrics.overrideAttrs (old: rec {
        version = "0.4.6";
        src = super.fetchFromGitHub {
          owner = "waylyrics";
          repo = "waylyrics";
          rev = "v${version}";
          hash = "sha256-CwfF6+YtcMmZGC6Y2pik6KwS7Cga/5n6fcifVbjgnFo=";
        };
        cargoHash = "sha256-6TlL7sJskqit64cRfN2mHwLJPZti+nzNIMHYgOk3NW0=";
        buildInputs = (old.buildInputs or [ ]) ++ [ super.gtk4-layer-shell ];
        cargoBuildFeatures = (old.cargoBuildFeatures or [ ]) ++ [ "layer-shell" ];
      });
    })
  ];
}
