{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;

  commandLineArgs = [
    # Force to run on Wayland
    "--ozone-platform-hint=auto"
    "--ozone-platform=wayland"
    "--enable-wayland-ime"
    # QQ electron does not support v3 at all
    # "--wayland-text-input-version=3"
  ];
in
mkHM (
  { pkgs, ... }:
  {
    home.packages = with pkgs; [
      telegram-desktop
      (qq.override { inherit commandLineArgs; })
      feishu
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
