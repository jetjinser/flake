{ self
, inputs
, ...
}:

let
  mkNixOS = import ../../lib/mkOS/mkNixOS.nix;
  mkNixOSFixed =
    system: username: modules: mkNixOS
      ({
        inherit (inputs) nixpkgs home-manager;
        inherit system;

        specialArgs = {
          inherit username self inputs;
        };
      } // modules);
in
{
  inherit mkNixOSFixed;

  allNixOS = {
    # AliCloud VPS
    cosimo = mkNixOSFixed "x86_64-linux" "jinser" (
      import ./cosimo.nix inputs
    );

    # JDCloud VPS
    chabert = mkNixOSFixed "x86_64-linux" "jinser" (
      import ./chabert.nix inputs
    );

    # MieCloud PVE VPS
    sheep = mkNixOSFixed "x86_64-linux" "jinser" (
      import ./sheep.nix inputs
    );

    # Raspberry Pi 4B 4G
    karenina = mkNixOSFixed "aarch64-linux" "jinser" (
      import ./karenina.nix inputs
    );
  };
}
