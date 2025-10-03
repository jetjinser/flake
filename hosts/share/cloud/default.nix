{
  imports = [
    ./user.nix
    ./ssh.nix
  ];

  documentation = {
    doc.enable = false;
    man.enable = false;
  };
}
