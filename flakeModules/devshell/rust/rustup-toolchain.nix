{
  perSystem = { pkgs, config, ... }: {
    devshells.rustupToolchain =
      let
        rust-toolchain = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain).override {
          extensions = [ "rust-src" "rust-analyzer" ];
        };
      in
      {
        env = [ ];

        commands = [ ];

        packages = [
          rust-toolchain
        ];
      };
  };
}
