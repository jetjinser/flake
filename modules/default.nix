{ lib, ... }:

with lib;
{
  options.modules = mkOption {
    type = with types; attrsOf (attrsOf path);
  };

  config.modules = {
    nixos = {
      services = ./services;
    };
    home = {
      programs = ./home/programs;
    };
  };
}
