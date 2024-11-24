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
  # networking.proxy.default = "http://127.0.0.1:7890/";

  systemd.services.sing-box.wantedBy = lib.mkForce [ ];
  sops.secrets = {
    server = { };
    password = { };
    method = { };
  };
  services.sing-box =
    let
      proxy = lib.mergeAttrsList [
        {
          type = "shadowsocks";
          tag = "proxy";
          # server_port = 28018;
          server_port = 49148;
        }
        (secretGenerator
          [
            "server"
            "password"
            "method"
          ])
        {
          multiplex = {
            enabled = true;
            protocol = "h2mux";
            max_streams = 16;
            padding = false;
          };
        }
      ];
    in
    {
      enable = true;
      settings = {
        log.level = "warn";
        inbounds = [
          {
            type = "mixed";
            listen = "::";
            listen_port = 7890;
          }
        ];
        outbounds = [
          proxy
          {
            tag = "direct";
            type = "direct";
          }
          {
            tag = "block";
            type = "block";
          }
        ];
        route = {
          final = "direct";
          rules = [
            {
              outbound = "direct";
              geosite = [ "private" ];
            }
            {
              outbound = "proxy";
              type = "logical";
              mode = "or";
              rules = [
                { geosite = [ "geolocation-!cn" ]; }
                {
                  geoip = [ "cn" ];
                  invert = true;
                }
              ];
            }
            {
              outbound = "direct";
              type = "logical";
              mode = "and";
              rules = [
                { geosite = [ "cn" ]; }
                { geoip = [ "cn" ]; }
              ];
            }
          ];
        };
      };
    };

  systemd.services.sing-box.serviceConfig.UMask = "0077";
}
