# TODO: refactor it into flake module

mkOSLib:

let
  inherit (mkOSLib) mkMacosSystem mkLinuxSystem;
in
rec {
  allDarwin = {
    julien = mkMacosSystem ../hosts/julien;
  };

  allNixOS = {
    bendemann = mkLinuxSystem ../hosts/bendemann;
    dorothy = mkLinuxSystem ../hosts/dorothy;

    chabert = mkLinuxSystem ../hosts/chabert;
    sheep = mkLinuxSystem ../hosts/sheep;

    barnabas = mkLinuxSystem ../hosts/barnabas;
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

    barnabas = {
      hostname = "barnabas";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.aarch64-linux.activate.nixos allNixOS.barnabas;
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
