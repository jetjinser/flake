{
  config,
  flake,
  ...
}:

let
  inherit (config.users) users;
in
{
  imports = [ flake.inputs.quasique.nixosModules.default ];

  # sops.secrets = {
  #   qqNumber.owner = users.wakapi.name;
  # };
  services.quasique = {
    enable = true;
    # TODO: use path
    qq = "";
  };
}
