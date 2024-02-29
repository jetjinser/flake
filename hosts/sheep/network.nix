# information from miecloud

{
  networking = {
    useDHCP = false;

    interfaces = {
      ens18.ipv4.addresses = [{
        address = "192.168.114.72/21";
        prefixLength = 21;
      }];
    };
    defaultGateway = {
      address = "192.168.113.254";
      interface = "ens18";
    };

    nameservers = [
      "119.29.29.29"
    ];
  };

  services.qemuGuest.enable = true;
}
