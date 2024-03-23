{ config
, lib
, ...
}:

let
  # TODO: route rules
  enable = true;

  inherit (config.sops) secrets;

  mkSecret = k: {
    _secret = secrets.${k}.path;
  };
  secretGenerator = with lib; flip genAttrs mkSecret;
in
{
  # TODO: change module path
  imports = [
    ../../../modules/darwinModules
  ];

  servicy.sing-box =
    let
      mie-proxy = lib.mergeAttrsList [
        {
          type = "vmess";
          tag = "mie-proxy";
          server_port = 18754;
        }
        (secretGenerator
          [
            "server"
            "uuid"
            "security"
          ])
      ];
    in
    {
      inherit enable;
      settings = {
        inbounds = [
          {
            type = "mixed";
            listen = "::";
            listen_port = 7890;
          }
        ];
        outbounds = [ mie-proxy ];
      };
    };
}
