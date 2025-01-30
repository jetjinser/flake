{ flake
, ...
}:

let
  inherit (flake.config.lib) importx;
in
{
  imports = importx ./. { };

  services.cloudflared.enable = true;
}
