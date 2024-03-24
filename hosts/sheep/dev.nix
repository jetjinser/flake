{ pkgs
, flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  users.users.${myself}.extraGroups = [ "docker" ];
}
