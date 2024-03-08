{ self
, inputs
, ...
}:

let
  mkDarwin = import ../../lib/mkOS/mkDarwin.nix;
  mkDarwinFixed =
    system: username: modules: mkDarwin
      ({
        inherit (inputs) nix-darwin home-manager;
        inherit system;

        specialArgs = {
          inherit username self inputs;
        };

        overlays = [
          inputs.neovim-nightly-overlay.overlay
        ];
      } // modules);
in
{
  inherit mkDarwinFixed;

  allDarwin = {
    # MacBookPro16 intel, provided by the company
    julien = mkDarwinFixed "x86_64-darwin" "jinserkakfa" (
      import ./julien.nix inputs
    );
  };
}
