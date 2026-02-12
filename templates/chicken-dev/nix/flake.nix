{
  description = "A startup Chicken project with devshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.chicken
        ]
        ++ (with pkgs.chickenPackages.chickenEggs; [
          srfi-13
        ]);
      };
    };
}
