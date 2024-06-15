{ lib
, config
, ...
}:

{
  perSystem = { pkgs, ... }:
    let
      inherit (pkgs.stdenv) isLinux;
      inherit (config.malib pkgs) mkCmdGroup;
      NixOSCmdGroup = mkCmdGroup "NixOS" [
        {
          name = "swos";
          help = "Switch system to contain a specified system configuration output";
          command = builtins.readFile (pkgs.substitute {
            src = ../../scripts/devshell/nixos/switch.sh;
            replacements = [
              "--replace"
              "@nom@"
              (lib.getExe pkgs.nix-output-monitor)
            ];
          });
        }
      ];
    in
    {
      devshells.default = lib.optionalAttrs isLinux {
        commands = NixOSCmdGroup;
      };
    };
}
