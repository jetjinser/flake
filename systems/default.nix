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
    cosimo = mkLinuxSystem ../hosts/cosimo;
    sheep = mkLinuxSystem ../hosts/sheep;
    sheepro = mkLinuxSystem ../hosts/sheepro;

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
    cosimo = {
      hostname = "cosimo";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.x86_64-linux.activate.nixos allNixOS.cosimo;
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
    sheepro = {
      hostname = "sheepro";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = deployLib.x86_64-linux.activate.nixos allNixOS.sheepro;
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
