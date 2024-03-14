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
  imports = [
    ../../../modules/darwinModules
  ];

  servicy.sing-box =
    let
      mie-proxy = lib.mergeAttrsList [
        {
          type = "vmess";
          tag = "mie-proxy";
          server_port = 443;
          tls = {
            enabled = true;
            insecure = false;
          };
          transport = {
            type = "grpc";
            service_name._secret = secrets.serviceName.path;
          };
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
