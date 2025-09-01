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
      (feishu.override {
        commandLineArgs = [
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
        ];
      })
    ];
  }
)
// {
  imports = [ flake.config.modules.nixos.misc ];
  nixpkgs.superConfig.allowUnfreeList = [
    "qq"
    "feishu"
  ];

  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".local/share/TelegramDesktop"
    ];
  };
}
