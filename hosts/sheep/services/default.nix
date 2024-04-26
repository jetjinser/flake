let
  atticdName = "cache";
  atticdPort = "5688";

  # orgUrl = "yeufossa.org";
in
{
  imports = [
    (import ./cacheServer.nix {
      inherit atticdName atticdPort;
    })
    # (import ./tunnel.nix {
    #   inherit orgUrl atticdName atticdPort;
    # })
    # ./hydraOr.nix
    ./storage.nix
    ./biliup.nix
  ];
}
