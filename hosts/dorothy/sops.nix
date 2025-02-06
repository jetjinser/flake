{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
# inherit (config.users) users;
{
  imports = [ flake.inputs.sops-nix.nixosModules.sops ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      {
        directory = ".config/sops";
        inInitrd = true;
      }
    ];
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/home/${myself}/.config/sops/age/keys.txt";
    secrets = {
      # spotify_username = {
      #   owner = users.spotifyd.name;
      # };
      # spotify_password = {
      #   owner = users.spotifyd.name;
      # };
    };
  };
}
