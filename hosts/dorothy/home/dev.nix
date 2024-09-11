{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    guile
    radicle-node
  ];

  systemd.user.services.start-radicle-node = {
    Unit = { Description = "Start Radicle node"; };
    Service = {
      Type = "oneshot";
      ExecStart = toString (pkgs.writeShellScript "start-radicle-node"
        "exec ${pkgs.radicle-node}/bin/rad node start"
      );
      wantedBy = [ "multi-user.target" ];
    };
  };
}
