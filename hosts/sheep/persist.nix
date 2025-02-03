{ flake
, ...
}:

{
  imports = [ flake.inputs.preservation.nixosModules.preservation ];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      files = [ ];
      directories = [
        "/var/lib/nixos"
        "/var/log"
      ];
    };
  };
}
