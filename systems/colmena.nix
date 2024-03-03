{ self
, inputs
, nixpkgs
, ...
}:

let
  const = import ../const.nix;
  inherit (const.machines) aliyun jdcloud miecloud;
  inherit (const.whoami) username;

  inherit (import ../lib/mkOS) mkColmena;
  mkColmenaFixed =
    deployment: modules: mkColmena ({
      inherit deployment;
      inherit (inputs) home-manager;

      # could be pass to home-manager
      specialArgs = {
        inherit username;
      };
    } // modules);

  meta = {
    nixpkgs = import nixpkgs {
      system = "x86_64-linux";
    };
    specialArgs = {
      inherit username self inputs;
    };
  };

  machines = {
    cosimo = mkColmenaFixed
      {
        targetHost = aliyun.host;
        buildOnTarget = true;
      }
      (import ./nixos/cosimo.nix inputs);

    chabert = mkColmenaFixed
      {
        targetHost = jdcloud.host;
        buildOnTarget = true;
      }
      (import ./nixos/chabert.nix inputs);

    sheep = mkColmenaFixed
      {
        targetHost = miecloud.host;
        targetPort = miecloud.port;
        buildOnTarget = true;
      }
      (import ./nixos/sheep.nix inputs);
  };
in

{
  allColmena = {
    inherit meta;
  } // machines;
}
