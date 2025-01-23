{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.dorothy

    flake.inputs.sops-nix.nixosModules.sops

    # keep-sorted start
    ./configuration.nix
    ./disko-config.nix
    ./networking.nix
    ./font.nix
    ./persist.nix
    ./sops.nix
    ./services
    ./dev
    ./app
    ./desktop
    # keep-sorted end

    ../share/cloud/user.nix
  ];
}
