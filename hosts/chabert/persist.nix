{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    flake.inputs.preservation.nixosModules.preservation
  ];

  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [ "/var" ];
      users.${myself} = {
        directories = [ "project" ];
      };
    };
  };
}
