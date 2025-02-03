{ flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.sheep

    ./configuration.nix
    ./disko-config.nix
    ./network.nix
    ./persist.nix

    ./sops.nix
    ./services

    ../share/cloud
  ];

  nix.channel.enable = false;

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [ "project" ];
  };
}
