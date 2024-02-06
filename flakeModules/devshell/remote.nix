{
  env = [ ];
  commands =
    let category = "Remote";
    in
    [
      {
        inherit category;
        name = "ins-mino";
        help = "Use nixos-anywhere to remotely install cosmino to the specified host";
        command = ''
          nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#cosmino $@
        '';
      }
    ];
  packages = [ ];
}
