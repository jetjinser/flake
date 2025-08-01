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
    lib,
    ...
  }:

  {
    home.packages = with pkgs; [
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
      config = {
        ruler_mode = "1";
        font_size = "15";
        touchpad_sensitivity = "0.8";
        startup_commands = lib.concatStringsSep ";" [
          "toggle_horizontal_scroll_lock"
        ];
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
    programs.imv = {
      enable = true;
      settings = {
        binds = {
          y = "exec wl-copy < $imv_current_file";
          n = "next";
          N = "next 5";
          m = "prev";
          M = "prev 5";
        };
      };
    };
    programs.mpv = {
      enable = true;
    };

    home.file.".config/qutebrowser/rosepine" = {
      source = pkgs.fetchFromGitHub {
        owner = "aalbegr";
        repo = "qutebrowser-rose-pine";
        rev = "4662474db0fa6b52985f9e9ea9c3eca16a721b5b";
        sha256 = "sha256-YP+Y00Ag69eO8Xx2adAEVzHYp3DuvfSfHnPh7lUXhss=";
      };
    };
    programs.qutebrowser = {
      enable = true;
      quickmarks = {
        nixpkgs = "https://github.com/NixOS/nixpkgs";
        HM-options = "https://nix-community.github.io/home-manager/options.xhtml";
      };
      searchEngines = {
        w = "https://en.wikipedia.org/wiki/Special:Search?search={}&go=Go&ns0=1";
        aw = "https://wiki.archlinux.org/?search={}";
        nw = "https://wiki.nixos.org/index.php?search={}";
        g = "https://www.google.com/search?q={}";
        np = "https://search.nixos.org/packages?channel=unstable&type=packages&query={}";
        no = "https://search.nixos.org/options?channel=unstable&query={}";
        h = "https://hoogle.haskell.org/?hoogle={}";
      };
      settings = {
        window.hide_decoration = true;
        auto_save.session = true;
        session.lazy_restore = true;
        tabs.show = "multiple";
        # FIXME: `auto` does not working
        colors.webpage.preferred_color_scheme = "dark";
      };
      greasemonkey = [
        # (pkgs.writeText "dark-reader.js" # javascript
        #   ''
        #     // ==UserScript==
        #     // @name          Dark Reader (Unofficial)
        #     // @icon          https://darkreader.org/images/darkreader-icon-256x256.png
        #     // @namespace     DarkReader
        #     // @description   Inverts the brightness of pages to reduce eye strain
        #     // @version       4.7.15
        #     // @author        https://github.com/darkreader/darkreader#contributors
        #     // @homepageURL   https://darkreader.org/ | https://github.com/darkreader/darkreader
        #     // @run-at        document-end
        #     // @grant         none
        #     // @include       http*
        #     // @require       https://cdn.jsdelivr.net/npm/darkreader/darkreader.min.js
        #     // @noframes
        #     // ==/UserScript==
        #
        #     DarkReader.enable({
        #       brightness: 100,
        #       contrast: 90,
        #       sepia: 10
        #     });
        #   ''
        # )
      ];
      keyBindings = {
        normal = {
          "d" = "scroll-page 0 0.5";
          "u" = "scroll-page 0 -0.5";
          "<Ctrl-U>" = "undo";

          ",m" = "spawn umpv {url}";
          ",M" = "hint links spawn umpv {hint-url}";
          ";M" = "hint --rapid links spawn umpv {hint-url}";
        };
      };
      extraConfig = # python
        ''
          import rosepine
          rosepine.setup(c, "rose-pine-moon", True)
        '';
    };

    programs.firefox = {
      enable = true;
      policies = {
        # about:policies#documentation
        AutofillAddressEnabled = false;
        DisableAccounts = true;
        DisableAppUpdate = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";
        DisplayMenuBar = "never";
        DontCheckDefaultBrowser = true;
        ExtensionUpdate = false;
        HardwareAcceleration = true;
        Homepage.StartPage = "previous-session";
        TranslateEnabled = false;
        EnableTrackingProtection.Value = true;
        CaptivePortal = false;
        Preferences = {
          "browser.tabs.closeWindowWithLastTab" = false;
          "browser.startup.homepage" = "about:blank";
          "browser.newtabpage.enabled" = false;
          "sidebar.verticalTabs" = true;

          # https://wiki.archlinux.org/title/Firefox/Privacy
          "media.peerconnection.ice.default_address_only" = true;
          "network.captive-portal-service.enabled" = false;
          "browser.safebrowsing.malware.enabled" = false;
          "browser.safebrowsing.phishing.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;
        };
        ExtensionSettings = {
          "vimium-c@gdh1995.cn" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4474326/vimium_c-2.12.3.xpi";
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4488139/darkreader-4.9.106.xpi";
          };
          # KISS Translator
          "{fb25c100-22ce-4d5a-be7e-75f3d6f0fc13}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4291806/kiss_translator-1.8.11.xpi";
          };
          "zotero@chnm.gmu.edu" = {
            installation_mode = "force_installed";
            install_url = "https://www.zotero.org/download/connector/dl?browser=firefox&version=5.0.171";
          };
          "extension@one-tab.com" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/file/4175239/onetab-1.83.xpi";
          };
        };
        SearchEngines = {
          Add = [
            {
              Name = "Nix Packages";
              URLTemplate = "https://search.nixos.org/packages?channel=unstable&type=packages&query={searchTerms}";
              IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              Alias = "@np";
            }
            {
              Name = "Nix Options";
              URLTemplate = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
              IconURL = "file://${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              Alias = "@no";
            }
            {
              Name = "NixOS Wiki";
              URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
              IconURL = "https://wiki.nixos.org/nixos.png";
              Alias = "@nw";
            }
            {
              Name = "Hoogle";
              URLTemplate = "https://hoogle.haskell.org/";
              IconURL = "https://hoogle.haskell.org/hoogle.png";
              Alias = "@h";
            }
          ];
        };
      };
      profiles.jinser = {
        isDefault = true;
        settings = { };
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
      ".local/share/qutebrowser"
    ];
  };
}
