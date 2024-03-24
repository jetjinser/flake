let
  atticdName = "cache";
  atticdPort = "5688";

  orgUrl = "yeufossa.org";
in
{
  imports = [
    # (import ./cacheServer.nix {
    #   inherit orgUrl atticdName atticdPort;
    # })
    (import ./tunnel.nix {
      inherit orgUrl atticdName atticdPort;
    })
    # ./hydraOr.nix
    ./pgs.nix
    ./storage.nix
  ];
}
