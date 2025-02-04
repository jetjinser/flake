{ lib
, ...
}:

let
  nodePort = 9002;
in
{
  services.prometheus.exporters = {
    node = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = nodePort;
      enabledCollectors = [
        "systemd"
        "logind"
        "processes"
      ];
      extraFlags = [
        "--collector.systemd.enable-start-time-metrics"
      ];
    };
  };
}
