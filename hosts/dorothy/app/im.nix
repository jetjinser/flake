{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      telegram-desktop
      (qq.override {
        commandLineArgs = [
          "--wayland-text-input-version=3"
        ];
      })
      wemeet
    ];
  }
)
// {
  imports = [ flake.config.modules.nixos.misc ];
  nixpkgs.superConfig.allowUnfreeList = [
    "qq"
    "wemeet"
    "libwemeetwrap"
  ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".local/share/TelegramDesktop"
    ];
  };
}
