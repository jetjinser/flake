let
  enable = true;
in
{
  services.tailscale.derper = {
    inherit enable;
    domain = "mie.purejs.icu";
    port = 27968;
    stunPort = 27969;
    openFirewall = true;
    verifyClients = true;
    configureNginx = false;
  };
  networking.firewall.allowedTCPPorts = [
    27968
    27969
  ];
}
