{
  perSystem = { pkgs, ... }: {
    devshells.stable =
      let
        rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
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
