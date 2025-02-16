{
  flake,
  ...
}:

{
  imports = [ flake.inputs.preservation.nixosModules.preservation ];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [ ];
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }
        "/var/log"
      ];
    };
  };
}
