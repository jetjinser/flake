{ self
, inputs
,
}:

let
  mkDarwin = import ../lib/mkOS/mkDarwin.nix;
  mkNixOS = import ../lib/mkOS/mkNixOS.nix;
in
{
  allDarwin =
    let
      _mkDarwin =
        system: username: modules: mkDarwin
          ({
            inherit (inputs) nix-darwin home-manager;
            inherit system;

            specialArgs = {
              inherit username self inputs;
            };
          } // modules);
    in
    {
      # MacBookPro16 intel, provided by the company
      julien = _mkDarwin "x86_64-darwin" "jinserkakfa" {
        darwinModules = [
          ../modules/share
          ../hosts/julien
        ];
        homeModules = { ... }: {
          imports = [
            inputs.nix-index-database.hmModules.nix-index

            ../homeModules/base.nix
            ../homeModules/share
            ../homeModules/darwin
          ];
        };
      };
    };

  allNixOS =
    let
      _mkNixOS =
        system: username: modules: mkNixOS
          ({
            inherit (inputs) nixpkgs home-manager;
            inherit system;

            specialArgs = {
              inherit username self inputs;
            };
          } // modules);
    in
    {
      # AliCloud VPS
      cosimo = _mkNixOS "x86_64-linux" "jinser" {
        nixOSModules = [
          inputs.disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops
          inputs.simple-nixos-mailserver.nixosModule

          ../modules/share
          ../hosts/cosimo
        ];
        homeModules = { ... }: {
          imports = [
            inputs.nix-index-database.hmModules.nix-index

            ../homeModules/base.nix
            ../homeModules/share
          ];
        };
      };
    };
}
