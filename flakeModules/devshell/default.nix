{ inputs, lib, ... }:
{
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = { pkgs, config, ... }:
    {
      devshells.default =
        let
          inherit (pkgs.stdenv) isLinux isDarwin;
          ab = attr: lib.mkMerge [
            share.${attr}
            remote.${attr}

            (lib.mkIf isLinux nixos.${attr})
            (lib.mkIf isDarwin darwin.${attr})
          ];

          share = import ./share.nix { inherit pkgs; };
          darwin = import ./darwin.nix { inherit lib pkgs config; };
          nixos = import ./nixos.nix { inherit lib pkgs; };
          remote = import ./remote.nix;
        in
        {
          motd = ''
            {italic}{99}🦾 Life in Nix 👾{reset}
            $(type -p menu &>/dev/null && menu)
          '';
          name = "NixConsole";

          env = ab "env";
          commands = ab "commands";
          packages = ab "packages";
        };
    };
}
