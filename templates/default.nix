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

  java-dev = {
    path = ./java-dev;
    description = "A startup Java and Gradle project with devshell";
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
