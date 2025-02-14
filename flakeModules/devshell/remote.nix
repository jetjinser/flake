{
  config,
  ...
}:

{
  perSystem =
    { pkgs, ... }:
    let
      inherit (config.lib) mkCmdGroup;
      RemoteCmdGroup = mkCmdGroup "Remote" [
        {
          name = "anywhere";
          help = "Use nixos-anywhere to remotely install NixOS to the specified host";
          command = ''
            nix run github:nix-community/nixos-anywhere -- --build-on remote --flake .#$1 ''${@:2}
          '';
        }
        # {
        #   name = "deploy";
        #   help = "run deploy-rs";
        #   command = "nix run github:serokell/deploy-rs -- $@";
        # }
      ];
    in
    {
      devshells.default = {
        commands = RemoteCmdGroup;
        packages = [ pkgs.deploy-rs ];
      };
    };
}
