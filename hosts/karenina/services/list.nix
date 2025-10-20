{ config, ... }:

let
  cfg = config.services.openlist;

  enable = true;
in
{
  services.openlist = {
    inherit enable;
    openFirewall = true;
    settings = { };
  };
}
