{ flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    flake.inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "/persist/home/${myself}/.config/sops/age/keys.txt";
    secrets = {
      server = { };
      password = { };
      method = { };
    };
  };
}
