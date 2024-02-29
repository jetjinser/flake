{ nixos-generators
, system
, format
, specialArgs
, nixOSModules
, ...
}:

nixos-generators.nixosGenerate {
  inherit system format specialArgs;

  modules = nixOSModules;
}
