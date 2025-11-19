{
  pkgs,
  ...
}:

let
  # TODO: when those updated?
  ads-anti-ad = pkgs.fetchurl {
    url = "https://anti-ad.net/anti-ad-for-smartdns.conf";
    sha256 = "sha256-ijJErZsPkDLf32zL/IoBguwKb0cv8cAhJQM/cpoROmY=";
  };
  ads-adrules = pkgs.fetchurl {
    url = "https://adrules.top/smart-dns.conf";
    sha256 = "sha256-aE2xw1tmV6nwdtqVZ45sxCpBRM1DoNMoYCEIIAd4+Jw=";
  };
in
{
  services.smartdns = {
    enable = true;
    settings = {
      # both IPv4 & IPv6
      bind = "[::]:53";
      server = [
        "223.5.5.5"
        "1.1.1.1"
        "8.8.8.8"
      ];
      server-tls = [
        "8.8.8.8:853"
        "1.1.1.1:853"
      ];
      server-https = "https://cloudflare-dns.com/dns-query https://223.5.5.5/dns-query";
      address = [ "/hw-v2-web-player-tracker.biliapi.net/#" ];
      conf-file = [
        ads-anti-ad.outPath
        ads-adrules.outPath
      ];
    };
  };

  networking.nameservers = [
    "::1"
    "127.0.0.1"
  ];
}
