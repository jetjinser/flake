{
  inputs,
  ...
}:

{
  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.deploy-rs.overlays.default
        ];
      };
      packages.deploy-rs = pkgs.deploy-rs.deploy-rs;
    };
}
