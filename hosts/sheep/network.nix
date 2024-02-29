# information from miecloud

{
  networking = {
    interfaces = {
      net0.ipv4.addresses = [{
        address = "192.168.114.72/21";
        prefixLength = 21;
      }];
    };
    defaultGateway = {
      address = "192.168.113.254";
      interface = "net0";
    };

    nameservers = [
      "119.29.29.29"
    ];
  };

  services.qemuGuest.enable = true;
}
