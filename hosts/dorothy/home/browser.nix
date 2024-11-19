{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    nyxt
    zotero

    nautilus
    sushi
  ];

  programs.sioyek = {
    enable = true;
    bindings = {
      screen_down = [ "d" "<C-d>" ];
      screen_up = [ "u" "<C-u>" ];
      overview_next_item = "<C-n>";
      overview_prev_item = "<C-N>";
      toggle_dark_mode = "F9";
    };
    config = {
      ruler_mode = "1";
      ui_font = "15";
    } //
    # catppuccin mocha theme
    # copied from https://github.com/catppuccin/sioyek/blob/3e142d195e74c1d61239e0fa2e93347d6fa5eb55/themes/catppuccin-mocha.config
    {
      background_color = "#1e1e2e";

      text_highlight_color = "#f9e2af";
      visual_mark_color = "#7f849c";

      search_highlight_color = "#f9e2af";
      link_highlight_color = "#89b4fa";
      synctex_highlight_color = "#a6e3a1";

      highlight_color_a = "#f9e2af";
      highlight_color_b = "#a6e3a1";
      highlight_color_c = "#89dceb";
      highlight_color_d = "#eba0ac";
      highlight_color_e = "#cba6f7";
      highlight_color_f = "#f38ba8";
      highlight_color_g = "#f9e2af";


      custom_background_color = "#1e1e2e";
      custom_text_color = "#cdd6f4";

      ui_text_color = "#cdd6f4";
      ui_background_color = "#313244";
      ui_selected_text_color = "#cdd6f4";
      ui_selected_background_color = "#585b70";
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisablePocket = true;
      Preferences = {
        "browser.tabs.closeWindowWithLastTab" = false;
      };
      ExtensionSettings = {
        # not work, dunno why
        # "switchyomega@feliscatus.addons.mozilla.org" = {
        #   installation_mode = "force_installed";
        #   install_url = "https://addons.mozilla.org/firefox/downloads/file/848109/switchyomega-2.5.10.xpi";
        # };
        "vimium-c@gdh1995.cn" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4210117/vimium_c-1.99.997.xpi";
        };
        "addon@darkreader.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/file/4295557/darkreader-4.9.86.xpi";
        };
      };
    };
    profiles.jinser = {
      bookmarks = { };
      settings = { };
      search = {
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Wiki" = {
            urls = [{ template = "https://wiki.nixos.org/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://wiki.nixos.org/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "Bing".metaData.alias = "@b";
          "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        };
      };
    };
  };
}
