rec {
  default = devshell;

  devshell = {
    path = ./devshell;
    description = "A startup basic devshell project";
  };

  hs-dev = {
    path = ./hs-dev;
    description = "A startup Haskell project with devshell";
  };

  kt-dev = {
    path = ./kt-dev;
    description = "A startup Kotlin and Gradle project with devshell";
  };

  opam-dev = {
    path = ./opam-dev;
    description = "A startup OCaml (Opam) project with devshell";
  };

  python-dev = {
    path = ./python-dev;
    description = "A startup Python project with devshell";
  };

  rust-dev = {
    path = ./rust-dev;
    description = "A startup Rust project with devshell";
  };
}
