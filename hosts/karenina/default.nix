{ ... }:

{
  imports = [
    ./configuration.nix
    ./network.nix

    ../share/cloud
  ];

  # TODO: determine
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/NIXOS_SD";
  #     fsType = "ext4";
  #     options = [ "noatime" ];
  #   };
  # };
}
