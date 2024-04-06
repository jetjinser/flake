{ lib
, ...
}:

{
  services.openssh.ports = lib.mkForce [ 2234 ];
}
