{ pkgs
, username
, ...
}:

{
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  users.users.${username}.extraGroups = [ "docker" ];
}
