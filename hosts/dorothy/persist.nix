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
      # https://nix-community/impermanence/issues/178
      "/var/lib/nixos"

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
          ".config/nyxt"
          ".radicle"
          ".ssh"

          ".local/share/TelegramDesktop"
          ".local/share/sioyek"

          ".local/state/cabal"

          # TODO: drop it
          ".mozilla"
        ];
      };
  };
}
