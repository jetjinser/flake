let
  const = import ../../const.nix;
  inherit (const.machines) aliyun jdcloud;
in
{
  programs.ssh = {
    knownHosts = {
      cosimoED = {
        hostNames = [ "cosimo" "mimo" aliyun.host ];
        publicKeyFile = aliyun.publicKeyEDFile;
      };
      cosimoRSA = {
        hostNames = [ "cosimo" "mimo" aliyun.host ];
        publicKeyFile = aliyun.publicKeyRSAFile;
      };
      chabertED = {
        hostNames = [ "chabert" "cher" jdcloud.host ];
        publicKeyFile = jdcloud.publicKeyEDFile;
      };
      chabertRSA = {
        hostNames = [ "chabert" "cher" jdcloud.host ];
        publicKeyFile = jdcloud.publicKeyRSAFile;
      };
    };
  };
}
