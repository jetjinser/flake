# TODO: refactor it into flake module

mkOSLib:

let
  inherit (mkOSLib) mkLinuxSystem;
in
rec {
  allNixOS = {
    bendemann = mkLinuxSystem ../hosts/bendemann;
    dorothy = mkLinuxSystem ../hosts/dorothy;

    chabert = mkLinuxSystem ../hosts/chabert;
    sheep = mkLinuxSystem ../hosts/sheep;

    karenina = mkLinuxSystem ../hosts/karenina;
  };

  mkAllNodes = deployLib: {
    chabert = {
      hostname = "chabert";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.x86_64-linux.activate.nixos allNixOS.chabert;
      };
    };
    sheep = {
      hostname = "sheep";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.x86_64-linux.activate.nixos allNixOS.sheep;
      };
    };

    karenina = {
      hostname = "karenina";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.aarch64-linux.activate.nixos allNixOS.karenina;
      };
    };
  };
}
