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
    rpi4 = mkImageFixed "aarch64-linux" "sd-aarch64" {
      inherit (import ./scarecrow/rpi4 inputs) nixOSModules;
    };

    nanopi-r2s = mkImageFixed "aarch64-linux" "sd-aarch64" {
      inherit (import ./scarecrow/nanopi-r2s inputs) nixOSModules;
    };
  };
}
