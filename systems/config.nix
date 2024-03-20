{
  allDarwin = {
    julien = ../hosts/julien;
  };

  allNixOS = {
    chabert = ../hosts/chabert;
    barnabas = ../hosts/barnabas;
    karenina = ../hosts/karenina;
  };

  allNodes = {
    chabert = {
      hostname = "chabert";
      profiles.system = {
        user = "root";
        sshUser = "root";
        remoteBuild = true;
        # path = deployLib.x86_64-linux.activate.nixos allNixOS.chabert;
      };
    };
  };
}
