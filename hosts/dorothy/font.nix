{ pkgs
, ...
}:

{
  fonts.fontDir.enable = true;
  fonts = {
    packages = with pkgs; [
      dejavu_fonts

      # keep-sorted start
      source-han-mono
      source-han-sans
      source-han-serif
      # keep-sorted end

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
        serif = [ "DejaVu Serif" "Source Han Serif SC" ];
        sansSerif = [ "Dejavu Sans" "Source Han Sans SC" ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [ "RobotoMono Nerd Font Mono" "Source Han Mono SC" ];
      };
    };
    enableDefaultPackages = true;
  };
}
