{ flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  imports = [
    flake.inputs.impermanence.nixosModules.impermanence
  ];

  environment.persistence."/persist" = {
    users.${myself} = {
      directories = [
        "vie"
        ".config/nvim"
        ".config/sops"
        ".ssh"
      ];
    };
  };
}
