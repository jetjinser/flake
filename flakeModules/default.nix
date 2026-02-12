{ inputs, ... }:

{
  imports = [
    ./devshell
    ./formatter.nix
    ./overlays.nix
    ./qkgs.nix
    ./hook.nix
    ./topology.nix
  ];

  perSystem =
    {
      system,
      pkgs,
      self',
      ...
    }:
    {
      packages.run-image = pkgs.callPackage ../run-image.nix { };
      apps =
        let
          inherit (self'.packages) run-image;
          extendConfiguration = c: module: c.extendModules { modules = [ module ]; };
          image = p: p.config.system.build.image;

          vm-demo =
            arch:
            let
              demoSystem = "${arch}-linux";
              inherit (inputs.nixpkgs.legacyPackages.${demoSystem}) OVMF;
            in
            {
              type = "app";
              program =
                let
                  appl = extendConfiguration inputs.self.nixosConfigurations.barnabas {
                    nixpkgs = {
                      buildPlatform = system;
                      hostPlatform = demoSystem;
                    };
                    system.image.version = "1";
                    # services.lighttpd = {
                    #   enable = true;
                    #   document-root = self'.packages.update-v2;
                    # };
                  };

                in
                builtins.toString (
                  pkgs.writeShellScript "vm-demo" ''
                    ${
                      run-image.override {
                        targetArch = arch;
                        inherit OVMF;
                      }
                    }/bin/run-image ${image appl}/barnabas_1.raw
                  ''
                );
            };
        in
        {
          default = inputs.self.apps.${system}."vm-demo-${pkgs.stdenv.hostPlatform.qemuArch}";
          vm-demo-x86_64 = vm-demo "x86_64";
          vm-demo-aarch64 = vm-demo "aarch64";
        };
    };
}
