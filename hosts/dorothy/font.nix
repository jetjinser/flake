{ pkgs
, ...
}:

{
  fonts.fontDir.enable = true;
  fonts = {
    packages = with pkgs; [
      # Serif fonts
      dejavu_fonts
      noto-fonts-cjk-sans

      source-han-serif

      # emoji
      # openmoji-color
      noto-fonts-emoji

      # Mono fonts
      (nerdfonts.override {
        fonts = [
          "RobotoMono"
        ];
      })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Source Han Serif" ];
        sansSerif = [ "Dejavu Sans" ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [
          "RobotoMono Nerd Font Mono"
          "LXGW WenKai"
        ];
      };
    };
    enableDefaultPackages = true;
  };
}
