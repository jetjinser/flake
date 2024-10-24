{ config
, ...
}:

let
  inherit (config.users) users;
  inherit (config.sops) secrets;
in
{
  services.radicle = {
    enable = true;
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAaMWa9Od5wh1+ozsjKg4KJvh1jR/UBXgHY1DQLGTfqA radicle";
    privateKeyFile = secrets.radPriKey.path;
    httpd = {
      enable = true;
      listenPort = 8009;
    };
    node = {
      listenPort = 8776;
      openFirewall = true;
    };
    settings = {
      cli.hints = true;
      web.pinned.repositories = [
        "rad:z34hw569NHRuTVKHmQh2vBwu3HsPQ" # flake
      ];
      node = {
        alias = "seed.purejs.icu";
        connect = [ ];
        externalAddresses = [ "seed.purejs.icu:8776" ];
        limits = {
          connection = {
            inbound = 128;
            outbound = 16;
          };
          fetchConcurrency = 1;
          gossipMaxAge = 1209600;
          maxOpenFiles = 4096;
          rate = {
            inbound = {
              capacity = 1024;
              fillRate = 5.0;
            };
            outbound = {
              capacity = 2048;
              fillRate = 10.0;
            };
          };
          routingMaxAge = 604800;
          routingMaxSize = 1000;
        };
        listen = [ ];
        log = "INFO";
        network = "main";
        peers = {
          type = "dynamic";
        };
        relay = "auto";
        seedingPolicy = {
          default = "block";
        };
        workers = 8;
      };
      preferredSeeds = [
        "z6MkrLMMsiPWUcNPHcRajuMi9mDfYckSoJyPwwnknocNYPm7@seed.radicle.garden:8776"
        "z6Mkmqogy2qEM2ummccUthFEaaHvyYmYBYh3dbe9W4ebScxo@ash.radicle.garden:8776"
      ];
      publicExplorer = "https://app.radicle.xyz/nodes/$host/$rid$path";
    };
  };

  sops = {
    secrets.radPriKey = {
      owner = users.radicle.name;
    };
  };
}
