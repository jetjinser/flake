{
  pkgs,
  ...
}:

{
  fonts.fontDir.enable = true;
  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      inriafonts

      # keep-sorted start
      source-han-mono
      source-han-sans
      source-han-serif
      # keep-sorted end

      # Emoji
      noto-fonts-emoji

      # Mono fonts
      nerd-fonts.blex-mono

      # Icon
      icomoon-feather
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "DejaVu Serif"
          "Source Han Serif SC"
        ];
        sansSerif = [
          "Dejavu Sans"
          "Source Han Sans SC"
        ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [
          "BlexMono Nerd Font Mono"
          "Source Han Mono SC"
        ];
      };
    };
    enableDefaultPackages = true;
  };
}
