{ pkgs
, flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # keep-sorted start
    dive # look into docker image layers
    podman-compose # start group of containers for dev
    podman-tui # status of containers in the terminal
    # keep-sorted end
  ];

  environment.persistence."/persist" = {
    users.${myself}.directories = [
      # podman
      ".local/share/containers"
    ];
  };
}
