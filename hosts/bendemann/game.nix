{
  flake,
  pkgs,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  environment.systemPackages = with pkgs; [
    prismlauncher
  ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
