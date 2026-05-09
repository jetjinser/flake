{
  flake,
  pkgs,
  lib,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  enable = false;
in
{
  config = lib.mkIf enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    users.users."${myself}".extraGroups = [
      "kvm"
      "libvirtd"
    ];

    # preservation.preserveAt."/persist" = {
    #   directories = [ "/var/lib/libvirt" ];
    #   users.${myself}.directories = [
    #     ".local/share/libvirt"
    #   ];
    # };
  };
}
