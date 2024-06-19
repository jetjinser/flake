{ pkgs
, ...
}:

{
  fonts.fontDir.enable = true;
  fonts = {
    packages = with pkgs; [
      dejavu_fonts

      source-han-serif
      source-han-sans
      source-han-mono

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
        serif = [ "DejaVu Serif" "Source Han Serif" ];
        sansSerif = [ "Dejavu Sans" "Source Han Sans" ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [ "RobotoMono Nerd Font Mono" "Source Han Mono" ];
      };
    };
    enableDefaultPackages = true;
  };
}
