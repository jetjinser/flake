{ pkgs
, lib
, flake
, ...
}:

{
  imports = [
    flake.inputs.nix-topology.nixosModules.default
  ];

  environment.systemPackages = map lib.lowPrio (with pkgs; [
    # keep-sorted start
    curl
    file
    git
    jq
    screen
    zuo
    # keep-sorted end
  ]);
}
