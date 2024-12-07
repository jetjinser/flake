{ flake
, ...
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
      files = [ ];
      directories = [
        # https://nix-community/impermanence/issues/178
        "/var/lib/nixos"
        { directory = "/var/log"; inInitrd = true; }
      ];
      users.${myself} = {
        files = [ ];
        directories = [
          "Downloads"
          "Documents"
          "vie"

          ".radicle"
          { directory = ".ssh"; mode = "0700"; }
          ".mozilla"

          ".config/nyxt"

          ".local/share/TelegramDesktop"
          ".local/share/sioyek"
          ".local/share/Zotero"
          ".local/state/cabal"

          ".config/nvim"
          ".local/state/nvim"
          ".local/share/nvim"
        ];
      };
    };
  };
  systemd.tmpfiles.settings.preservation = {
    "/home/${myself}/.config".d = { user = myself; group = "users"; mode = "0755"; };
    "/home/${myself}/.local".d = { user = myself; group = "users"; mode = "0755"; };
    "/home/${myself}/.local/share".d = { user = myself; group = "users"; mode = "0755"; };
    "/home/${myself}/.local/state".d = { user = myself; group = "users"; mode = "0755"; };
  };
}
