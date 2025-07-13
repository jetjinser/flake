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
          # Force to run on Wayland
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          "--enable-wayland-ime"
        ];
      })
      (feishu.override {
        commandLineArgs = [
          # Force to run on Wayland
          "--ozone-platform-hint=auto"
          "--ozone-platform=wayland"
          "--enable-wayland-ime"
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
