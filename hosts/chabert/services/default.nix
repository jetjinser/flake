{
  flake,
  ...
}:

let
  inherit (flake.config.lib) importx;
in
{
  imports = (importx ./. { }) ++ [
    flake.config.modules.nixos.services
  ];

  preservation.preserveAt."/persist" = {
    directories = [ "/var/lib" ];
  };
}
