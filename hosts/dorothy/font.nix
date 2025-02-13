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

      # APL
      apl386
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
      # TODO: figure out
      # localConf = ''
      #   <match target="font">
      #       <test name="charset">
      #           <charset>
      #               <range>
      #                 <int>0x007f</int>
      #                 <int>0x2b2b</int>
      #               </range>
      #           </charset>
      #       </test>
      #       <edit name="family" mode="prepend">
      #           <string>APL386 Unicode</string>
      #       </edit>
      #   </match>
      # '';
    };
    enableDefaultPackages = true;
  };
}

# `ls-chars.sh``:
# #!/usr/bin/env bash
# for range in $(fc-match --format='%{charset}\n' "$1"); do
#     for n in $(seq "0x${range%-*}" "0x${range#*-}"); do
#         printf "%04x\n" "$n"
#     done
# done | while read -r n_hex; do
#     count=$((count + 1))
#     printf "%-5s\U$n_hex\t" "$n_hex"
#     [ $((count % 10)) = 0 ] && printf "\n"
# done
# printf "\n"
