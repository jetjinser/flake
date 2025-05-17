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
      directories = [
        "/var/lib/nixos"
        "/var/log"
      ];
      users.${myself} = {
        directories = [ "project" ];
      };
    };
  };
  systemd.tmpfiles.settings.preservation = {
    "/home/${myself}/project".d = {
      user = myself;
      group = "users";
      mode = "0755";
    };
  };
}
