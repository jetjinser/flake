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
    ];
    users.${myself} =
      let
        # considering...
        ded = [
          "Downloads"
        ];
      in
      {
        directories = ded ++ [
          "vie"
          ".config/nvim"
          ".config/sops"
          ".ssh"

          # podman
          ".local/share/containers"
        ];
      };
  };
}
