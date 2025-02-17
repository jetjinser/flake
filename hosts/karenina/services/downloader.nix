{
  services.deluge = {
    enable = true;
    declarative = true;
    openFirewall = true;
    web = {
      enable = true;
      port = 8112;
    };
  };
}
