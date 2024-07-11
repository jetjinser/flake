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
    directories = [
      "/var/guix"
      "/var/log"
    ];
    users.${myself} =
      let
        # considering...
        desktopFolders = [
          "Downloads"
        ];
      in
      {
        directories = desktopFolders ++ [
          "vie"
          ".config/nvim"
          ".config/sops"
          ".ssh"

          # TODO: drop it
          ".mozilla"
        ];
      };
  };
}
