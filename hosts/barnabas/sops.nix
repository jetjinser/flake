{ flake
, ...
}:

{
  imports = [ flake.inputs.sops-nix.nixosModules.sops ];
  sops.defaultSopsFile = ./secrets.yaml;
}
