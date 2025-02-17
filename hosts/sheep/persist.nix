{
  flake,
  ...
}:

{
  imports = [ flake.inputs.preservation.nixosModules.preservation ];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/var/lib/nixos"
        "/var/log"
      ];
    };
  };
}
