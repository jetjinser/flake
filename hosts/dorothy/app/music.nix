{
  flake,
  ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  services.mpd = {
    # TODO
    enable = false;
    musicDirectory = "/home/${myself}/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };
}
