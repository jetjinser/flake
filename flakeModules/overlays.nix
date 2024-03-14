{ inputs
, ...
}:

{
  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [
        (import inputs.rust-overlay)
        inputs.attic.overlays.default
      ];
    };
  };
}
