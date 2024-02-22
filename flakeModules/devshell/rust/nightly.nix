{
  perSystem = { pkgs, config, ... }: {
    devshells.nightly =
      let
        rust-toolchain = pkgs.rust-bin.nightly.latest.default.override {
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
