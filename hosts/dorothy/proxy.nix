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
  # NOTE: global, since SwitchyOmega does not work on my Firefox
  networking.proxy.default = "http://127.0.0.1:7890/";

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
