{
  pkgs,
  lib,
  ...
}:

{
  fonts.fontDir.enable = true;
  fonts = {
    packages =
      let
        # https://cat-in-136.github.io/2010/02/fontforge-script-to-merge-and-replace.html
        APLPatchedBlexMono = pkgs.runCommand "patch-APL-BlexMono" { } ''
          ${lib.getExe' pkgs.fontforge "fontforge"} -lang=ff -c '
            Open("${pkgs.apl386}/share/fonts/truetype/APL386.ttf");
            Select(0u0020, 0u00FF);
            Cut();
            MergeFonts("${pkgs.nerd-fonts.blex-mono}/share/fonts/truetype/NerdFonts/BlexMono/BlexMonoNerdFontMono-Regular.ttf");
            SetFontNames("BlexMono-Nerd-Font-APL-Mono", "BlexMono Nerd Font APL Mono", "BlexMono Nerd Font APL Mono", "Regular");
            Generate("BlexMonoNerdFontAPLMono-Regular.ttf", "", 4);'

          mkdir -p $out/share/fonts/truetype/
          ls -a
          cp ./BlexMonoNerdFontAPLMono-Regular.ttf $out/share/fonts/truetype/
        '';
      in
      with pkgs;
      [
        dejavu_fonts
        inriafonts

        # keep-sorted start
        arphic-ukai
        source-han-mono
        source-han-sans
        source-han-serif
        # keep-sorted end

        # Emoji
        noto-fonts-color-emoji

        # Mono fonts
        nerd-fonts.blex-mono

        # Icon
        icomoon-feather

        # APL
        apl386
        APLPatchedBlexMono
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
          "BlexMono Nerd Font APL Mono"
          "Source Han Mono SC"
        ];
      };
    };
    enableDefaultPackages = true;
  };
}
