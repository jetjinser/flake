rec {
  default = devshell;

  devshell = {
    path = ./devshell;
    description = "A startup basic devshell project";
  };

  rust-dev = {
    path = ./rust-dev;
    description = "A startup rust project with devshell";
  };

  python-dev = {
    path = ./python-dev;
    description = "A startup python project with devshell";
  };
}
