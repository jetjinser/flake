{ self
, inputs
, ...
}:

let
  mkImage = import ../lib/mkOS/mkImage.nix;
  mkImageFixed =
    system: format: modules: mkImage
      ({
        inherit (inputs) nixpkgs nixos-generators;
        inherit system format;

        specialArgs = {
          inherit self inputs;
        };
      } // modules);
in
{
  inherit mkImageFixed;

  allImages = {
    # Raspberry Pi 4B 4G
    karenina = mkImageFixed "aarch64-linux" "sd-aarch64" {
      inherit (import ./scarecrow inputs) nixOSModules;
    };
  };
}
