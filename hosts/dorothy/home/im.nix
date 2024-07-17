{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    telegram-desktop
    # qq
    (qq.override {
      commandLineArgs = [
        # Force to run on Wayland
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "--enable-wayland-ime"
      ];
    })
  ];
}
