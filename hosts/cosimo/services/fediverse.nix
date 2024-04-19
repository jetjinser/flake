{ pkgs
, ...
}:

{
  imports = [
    ../../../modules/servicy/betula.nix
  ];

  nixpkgs.overlays = [
    (final: prev: {
      betula = prev.betula.overrideAttrs (old: {
        version = "1.2.0";
        src = old.src.overrideAttrs (oldSrc: {
          hash = "sha256-oxwOGpf305VDlY3Mwl0dRJRRhe0yolaMMlpNspZdKQk=";
        });
        vendorHash = "sha256-DjL2h6YKCJOWgmR/Gb0Eja38yJ4DymqW/SzmPG3+q9w=";
      });
    })
  ];

  servicy.betula = {
    enable = true;
    package = pkgs.betula;
    openFirewall = true;
  };
}
