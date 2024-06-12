{ config
, lib
, ...
}:

let
  inherit (config.sops) secrets;

  mkSecret = k: {
    _secret = secrets.${k}.path;
  };
  secretGenerator = with lib; flip genAttrs mkSecret;
in
{
  services.sing-box =
    let
      mie-proxy = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "mie-proxy";
          server_port = 28018;
        }
        (secretGenerator
          [
            "server"
            "password"
            "method"
          ])
      ];
    in
    {
      enable = true;
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
