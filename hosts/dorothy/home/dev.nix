{ pkgs
, ...
}:

let
  flakeRoot = ../../../.;
  base = pkgs.writeScriptBin "base" (builtins.readFile (flakeRoot + /scripts/base.scm));
in
{
  home.packages = with pkgs; [
    guile
    radicle-node
    base
  ];

  # systemd.user.services.start-radicle-node = {
  #   Unit.Description = "Start Radicle node";
  #   Install.WantedBy = [ "multi-user.target" ];
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = toString (pkgs.writeShellScript "start-radicle-node"
  #       "exec ${pkgs.radicle-node}/bin/rad node start --foreground"
  #     );
  #   };
  # };
}
