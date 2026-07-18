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
        mkBlexApl =
          {
            withMath ? false,
          }:
          let
            variant = if withMath then "math" else "no-math";
            variants = {
              no-math = {
                math = "";
                mathSpace = "";
                mathDash = "";
                removeMath = true;
              };
              math = {
                math = "Math";
                mathSpace = "Math ";
                mathDash = "-Math";
                removeMath = false;
              };
            };
            selected = variants.${variant};
          in
          pkgs.runCommand "patch-APL-BlexMono-${variant}" { buildInputs = [ pkgs.fontforge ]; }
            # python
            ''
              fontforge -lang=py -c '
              import fontforge
              # APL386.otf has proper glyph outlines; APL386.ttf has empty slots for some symbols (e.g. U+2203).
              f = fontforge.open("${pkgs.apl386}/share/fonts/opentype/APL386.otf")
              f.selection.select(("ranges",), 0x0020, 0x00FF)
              f.cut()
              f.mergeFonts("${pkgs.nerd-fonts.blex-mono}/share/fonts/truetype/NerdFonts/BlexMono/BlexMonoNerdFontMono-Regular.ttf")
              ${lib.optionalString selected.removeMath ''
                f.selection.select(("ranges",), 0x2200, 0x22FF)
                f.clear()''}
              f.fontname = "BlexMono-Nerd-Font-APL${selected.mathDash}-Mono"
              f.familyname = "BlexMono Nerd Font APL ${selected.mathSpace}Mono"
              f.fullname = "BlexMono Nerd Font APL ${selected.mathSpace}Mono"
              f.generate("BlexMonoNerdFontAPL${selected.math}Mono-Regular.ttf")
              f.close()'

              mkdir -p $out/share/fonts/truetype/
              cp ./BlexMonoNerdFontAPL${selected.math}Mono-Regular.ttf $out/share/fonts/truetype/
            '';
        APLPatchedBlexMono = mkBlexApl { withMath = false; };
        APLPatchedBlexMonoMath = mkBlexApl { withMath = true; };
      in
      with pkgs;
      [
        # SSM
        dejavu_fonts
        inriafonts
        crimson-pro

        # keep-sorted start
        source-han-mono
        source-han-sans
        source-han-serif
        # keep-sorted end

        # Serif

        # Sans Serif
        source-sans-pro

        # Mono
        nerd-fonts.blex-mono

        # Emoji
        noto-fonts-color-emoji

        # APL
        apl386
        APLPatchedBlexMono
        APLPatchedBlexMonoMath

        # fallback
        freefont_ttf
        liberation_ttf
        unifont
      ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Inria Serif"
          "Source Han Serif SC"
        ];
        sansSerif = [
          "Inria Sans"
          "Source Han Sans SC"
        ];
        emoji = [ "Noto Color Emoji Regular" ];
        monospace = [
          "BlexMono Nerd Font APL Mono"
          "Source Han Mono SC"
        ];
      };
    };
    enableDefaultPackages = false;
  };
}
