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
    users.${myself} =
      let
        # considering...
        ded = [
          "Desktop"
          "Documents"
          "Downloads"
          "Music"
          "Pictures"
          "Public"
          "Templates"
          "Videos"
        ];
      in
      {
        directories = ded ++ [
          "vie"
          ".config/nvim"
          ".config/sops"
          ".ssh"
        ];
      };
  };
}
