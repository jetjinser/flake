{
  g = "git";
  n = "nvim";
  cdtmp = "cd (mktemp -d /tmp/jinser-XXXXXX)";
  decolorize = "sed -r \"s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g\"";
  nf = "nix flake";
  ns = "nix shell";
  eproxy = "set -e {HTTP, HTTPS, ALL, FTP, RSYNC}_PROXY";
  bh = "bat --plain --language=help";
  hl = "bat -pp -l";
  sc = "systemctl";
  jc = "journalctl";
}
