{ self
, inputs
, nixpkgs
, ...
}:

let
  inherit (import ../lib/mkOS) mkColmena;
  mkColmenaFixed =
    username: deployment: modules: mkColmena ({
      inherit deployment;
      inherit (inputs) home-manager;

      specialArgs = {
        inherit username;
      };
    } // modules);

  meta = {
    nixpkgs = import nixpkgs {
      system = "x86_64-linux";
    };
    specialArgs = {
      inherit self inputs;
    };
  };

  const = import ../const.nix;
  inherit (const.machines) aliyun jdcloud;
  machines = {
    cosimo = mkColmenaFixed "jinser"
      {
        targetHost = aliyun.host;
        buildOnTarget = true;
      }
      (import ./nixos/cosimo.nix inputs);

    chabert = mkColmenaFixed "jinser"
      {
        targetHost = jdcloud.host;
        buildOnTarget = true;
      }
      (import ./nixos/chabert.nix inputs);
  };
in

{
  allColmena = {
    inherit meta;
  } // machines;
}
