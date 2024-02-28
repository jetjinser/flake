let
  const = import ../../const.nix;
  inherit (const.machines) aliyun jdcloud miecloud;

  cosimoHosts = [ "cosimo" "mimo" aliyun.host ];
  chabertHosts = [ "chabert" "cher" jdcloud.host ];
  sheepHosts = [
    "sheep"
    "mie"
    "[${miecloud.host}]:${toString miecloud.port}"
  ];
in
{
  programs.ssh = {
    knownHosts = {
      cosimoED = {
        hostNames = cosimoHosts;
        publicKeyFile = aliyun.publicKeyEDFile;
      };
      cosimoRSA = {
        hostNames = cosimoHosts;
        publicKeyFile = aliyun.publicKeyRSAFile;
      };

      chabertED = {
        hostNames = chabertHosts;
        publicKeyFile = jdcloud.publicKeyEDFile;
      };
      chabertRSA = {
        hostNames = chabertHosts;
        publicKeyFile = jdcloud.publicKeyRSAFile;
      };

      sheepED = {
        hostNames = sheepHosts;
        publicKeyFile = miecloud.publicKeyEDFile;
      };
      sheepRSA = {
        hostNames = sheepHosts;
        publicKeyFile = miecloud.publicKeyRSAFile;
      };
      sheepECDSA = {
        hostNames = sheepHosts;
        publicKeyFile = miecloud.publicKeyECDSAFile;
      };
    };
  };
}
