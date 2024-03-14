{ inputs
, config
, ...
}:

let
  inherit (config.sops) secrets;
in
{
  imports = [
    inputs.typhon.nixosModules.default
  ];

  services.typhon = {
    enable = true;
    hashedPasswordFile = secrets.TyphonPWD.path;
    # default
    # port 3000 that cannot config
    # home = "/var/lib/typhon";
  };
}
