{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
  inherit (flake.config.lib) mkHM;
in
mkHM (
  {
    pkgs,
    ...
  }:

  {
    home.packages = with pkgs; [
      # nyxt
      zotero

      nautilus
      sushi
    ];

    programs.sioyek = {
      enable = true;
      bindings = {
        screen_down = [
          "d"
          "<C-d>"
        ];
        screen_up = [
          "u"
          "<C-u>"
        ];
        overview_next_item = "<C-n>";
        overview_prev_item = "<C-N>";
        toggle_custom_mode = "F9";
      };
      config =
        {
          ruler_mode = "1";
          font_size = "15";
        }
        //
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
          "vimium-c@gdh1995.cn" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4210117/vimium_c-1.99.997.xpi";
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4295557/darkreader-4.9.96.xpi";
          };
          # raindrop.io
          "jid0-adyhmvsP91nUO8pRv0Mn2VKeB84@jetpack" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4387956/raindropio-6.6.62.xpi";
          };
          # Immersive Translate
          "{5efceaa7-f3a2-4e59-a54b-85319448e305}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4389110/immersive_translate-1.11.4.xpi";
          };
        };
      };
      profiles.jinser = {
        settings = { };
        search = {
          # clear `search.json.mozlz4` generated by FireFox
          force = true;
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://wiki.nixos.org/w/index.php";
                  params = [
                    {
                      name = "search";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "https://wiki.nixos.org/nixos.png";
              definedAliases = [ "@nw" ];
            };

            "Hoogle" = {
              urls = [
                {
                  template = "https://hoogle.haskell.org/";
                  params = [
                    {
                      name = "hoogle";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "https://hoogle.haskell.org/hoogle.png";
              definedAliases = [ "@h" ];
            };

            "bing".metaData.hidden = true;
            "google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
          };
        };
      };
    };
  }
)
// {
  preservation.preserveAt."/persist" = {
    users.${myself}.directories = [
      ".mozilla"
      ".zotero"
      # ".config/nyxt"
      ".local/share/sioyek"
    ];
  };
}
