{
  env = [ ];
  commands =
    let category = "Remote";
    in
    [
      {
        inherit category;
        name = "rmt-ins";
        help = "Use nixos-anywhere to remotely install NixOS to the specified host";
        command = ''
          nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#$1 ''${@:2}
        '';
      }
    ];
  packages = [ ];
}
