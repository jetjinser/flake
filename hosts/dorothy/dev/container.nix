{
  pkgs,
  flake,
  ...
}:

let
  enable = false;

  inherit (flake.config.symbols.people) myself;
in
{
  virtualisation.containers.enable = enable;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker.enable = false;
  };

  environment.systemPackages = with pkgs; [
    # keep-sorted start
    dive # look into docker image layers
    podman-compose # start group of containers for dev
    podman-tui # status of containers in the terminal
    # keep-sorted end
  ];

  # users.users.${myself}.extraGroups = [ "docker" ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      # podman
      ".local/share/containers"
    ];
  };
}
