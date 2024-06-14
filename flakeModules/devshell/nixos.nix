{ pkgs, lib, ... }:

{
  env = [ ];

  commands =
    let category = "NixOS";
    in
    [
      {
        inherit category;
        name = "swos";
        help = "Switch system to contain a specified system configuration output";
        command = builtins.readFile (pkgs.substitute {
          src = ../../../scripts/devshell/nixos/switch.sh;
          replacements = [
            "--replace"
            "@nom@"
            (lib.getExe pkgs.nix-output-monitor)
          ];
        });
      }
      {
        inherit category;
        name = "mino";
        help = "Switch system to `cosimo`";
        command = "swos cosimo $@";
      }
    ];

  packages = [ ];
}
