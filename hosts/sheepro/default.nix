{
  flake,
  ...
}:

{
  imports = [
    # ../../troisModules/nixos/default.nix
    flake.self.nixosModules.sheepro

    ./configuration.nix
    ./sops.nix
    ./services

    ../share/cloud
  ];

  nix.channel.enable = false;

  networking.proxy.default = "http://192.168.114.1:8080";
}
