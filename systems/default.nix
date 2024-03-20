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
    chabert = mkLinuxSystem ../hosts/chabert;
    barnabas = mkLinuxSystem ../hosts/barnabas;
    karenina = mkLinuxSystem ../hosts/karenina;
  };

  mkAllNodes = deployLib: {
    chabert = {
      hostname = "chabert";
      profiles.system = {
        user = "root";
        sshUser = "root";
        remoteBuild = true;
        path = deployLib.x86_64-linux.activate.nixos allNixOS.chabert;
      };
    };
    barnabas = {
      hostname = "barnabas";
      profiles.system = {
        user = "root";
        sshUser = "root";
        remoteBuild = true;
        path = deployLib.aarch64-linux.activate.nixos allNixOS.barnabas;
      };
    };
    karenina = {
      hostname = "karenina";
      profiles.system = {
        user = "root";
        sshUser = "root";
        remoteBuild = true;
        path = deployLib.aarch64-linux.activate.nixos allNixOS.karenina;
      };
    };
  };
}
