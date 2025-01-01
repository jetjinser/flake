{ config
, pkgs
, lib
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
        "rad:z25xAFtusewgMho5r659gNtuNrXcU" # forest
        "rad:z4GDadj1B93ESJZ4Svi1D4yoHWM7P" # moonbit-compiler
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

  programs.ssh.startAgent = true;
  environment.systemPackages = [ pkgs.radicle-node ];
  systemd.user.timers."rad-mirror-github" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "rad-mirror-github.service";
    };
  };

  systemd.user.services."rad-mirror-github" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "rad-mirror-github";
        runtimeInputs = [ pkgs.git pkgs.radicle-node ];
        text = /* bash */ ''
          cd /home/jinser/mirror/flake
          echo "mirror flake"
          for i in 1 2 3 4 5; do if [[ $(git pull origin master) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "flake pulled"
          for i in 1 2 3 4 5; do if [[ $(git push rad master && echo 1) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "flake pushed"

          cd /home/jinser/mirror/forest
          echo "mirror forest"
          for i in 1 2 3 4 5; do if [[ $(git pull origin master) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "forest pulled"
          for i in 1 2 3 4 5; do if [[ $(git push rad master && echo 1) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "forest pushed"

          cd /home/jinser/mirror/moonbit-compiler
          echo "mirror moonbit-compiler"
          for i in 1 2 3 4 5; do if [[ $(git pull origin main) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "moonbit-compiler pulled"
          for i in 1 2 3 4 5; do if [[ $(git push rad main && echo 1) ]]; then break; else echo "retrying ($i)"; sleep 15; fi; done
          echo "moonbit-compiler pushed"
        '';
      });
    };
    environment.SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
  };
}
