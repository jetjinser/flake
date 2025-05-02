{
  config,
  lib,
  ...
}:

let
  cfg = config.services.cloudflared';
  defaultUser = "cloudflared-dns";
in
{
  options.services.cloudflared' = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to enable cloudflared";
      default = cfg.ingress != { };
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "User account under which betula runs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = defaultUser;
      description = "Group under which betula runs.";
    };

    tunnelID = lib.mkOption {
      type = lib.types.str;
    };
    domain = lib.mkOption {
      type = lib.types.str;
    };
    credentialsFile = lib.mkOption {
      type = lib.types.path;
    };
    certificateFile = lib.mkOption {
      type = lib.types.path;
    };
    ingress = lib.mkOption {
      type = with lib.types; lazyAttrsOf port;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      mkPrefix = x: if (x == "~") then "" else "${x}.";
    in
    {
      users.users = lib.mkIf (cfg.user == defaultUser) {
        ${defaultUser} = {
          inherit (cfg) group;
          isSystemUser = true;
        };
      };
      users.groups = lib.mkIf (cfg.group == defaultUser) {
        ${defaultUser} = { };
      };

      services.cloudflared =
        let
          serveIng = domain: subdomain: port: {
            "${mkPrefix subdomain}${domain}" = "http://localhost:${toString port}";
          };
          serveIng' = serveIng cfg.domain;
        in
        {
          inherit (cfg) enable;
          tunnels = {
            ${cfg.tunnelID} = {
              inherit (cfg) credentialsFile certificateFile;
              default = "http_status:404";
              ingress = lib.concatMapAttrs serveIng' cfg.ingress;
            };
          };
        };
      systemd.services."cloudflared-tunnel-dns-setup-${cfg.tunnelID}" = {
        description = "DNS Setup for Cloudflared Tunnel";
        after = [
          "network.target"
          "network-online.target"
        ];
        wants = [
          "network.target"
          "network-online.target"
        ];
        before = [ "cloudflared-tunnel-${cfg.tunnelID}.service" ];
        wantedBy = [ "multi-user.target" ];

        environment.TUNNEL_ORIGIN_CERT = cfg.certificateFile;

        script = lib.concatMapStringsSep "\n" (subdomain: ''
          ${config.services.cloudflared.package}/bin/cloudflared tunnel route dns ${cfg.tunnelID} ${mkPrefix subdomain}${cfg.domain}
        '') (builtins.attrNames cfg.ingress);

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          DynamicUser = true;
          User = cfg.user;
          Group = cfg.group;
        };
      };
    }
  );
}
