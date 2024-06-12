{ pkgs
, ...
}:

{
  programs.firefox = {
    enable = true;
    policies = {
      DisablePocket = true;
      Preferences = {
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.urlbar.autoFill.adaptiveHistory.enabled" = true;
        "browser.tabs.closeWindowWithLastTab" = false;
      };
    };
    profiles.jinser = {
      bookmarks = {};
      settings = {};
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
