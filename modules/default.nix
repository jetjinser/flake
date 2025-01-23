{ lib, ... }:

with lib;
{
  options.modules = mkOption {
    type = with types; attrsOf (attrsOf path);
  };

  config.modules = {
    nixos = {
      services = ./services;
      misc = ./misc;
    };
    home = {
      programs = ./home/programs;
    };
  };
}
