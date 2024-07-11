{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    nyxt
  ];

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
