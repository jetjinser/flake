{
  machines = {
    aliyun = {
      host = "106.14.161.118";

      publicKeyEDFile = ./pubkeys/aliyun/id_ed25519.pub;
      publicKeyRSAFile = ./pubkeys/aliyun/id_rsa.pub;
    };
    jdcloud = {
      host = "117.72.45.59";

      publicKeyEDFile = ./pubkeys/jdcloud/id_ed25519.pub;
      publicKeyRSAFile = ./pubkeys/jdcloud/id_rsa.pub;
    };
    miecloud = {
      host = "mie.purejs.icu";
      port = 38814;

      publicKeyEDFile = ./pubkeys/miecloud/id_ed25519.pub;
      publicKeyRSAFile = ./pubkeys/miecloud/id_rsa.pub;
      publicKeyECDSAFile = ./pubkeys/miecloud/id_ecdsa-sha2-nistp256.pub;
    };
  };
}
