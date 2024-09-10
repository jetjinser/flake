{ flake
, ...
}:

let
  inherit (flake.config.symbols.people) myself;
in
{
  services.mpd = {
    enable = true;
    musicDirectory = "/home/${myself}/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
    '';
  };
}

