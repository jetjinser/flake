{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    tdesktop
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
