{ flake
, ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.dorothy

    flake.inputs.sops-nix.nixosModules.sops

    # keep-sorted start
    ./app
    ./configuration.nix
    ./desktop
    ./dev
    ./disko-config.nix
    ./font.nix
    ./networking.nix
    ./persist.nix
    ./services
    ./sops.nix
    # keep-sorted end

    ../share/cloud/user.nix
  ];
}
