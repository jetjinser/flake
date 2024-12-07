{ pkgs
, ...
}:

let
  flakeRoot = ../../../.;
  base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));
in
{
  home.packages = with pkgs; [
    radicle-node
    base
  ];

  # dconf.settings = {
  #   "org/virt-manager/virt-manager/connections" = {
  #     autoconnect = [ "qemu:///system" ];
  #     uris = [ "qemu:///system" ];
  #   };
  # };
}
