{ inputs
, ...
}:

{
  imports = [
    inputs.devshell.flakeModule

    ./console
    ./rust
  ];
}
