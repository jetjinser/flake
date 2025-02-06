{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  virtualisation.libvirtd.enable = true;
  environment.systemPackages = [ pkgs.virt-viewer ];

  users.users."${myself}".extraGroups = [ "libvirtd" ];

  preservation.preserveAt."/persist" = {
    directories = [ "/var/lib/libvirt" ];
    users.${myself}.directories = [
      ".local/share/libvirt"
    ];
  };
}
